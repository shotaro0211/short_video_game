import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:gal/gal.dart';
import 'package:flutter_screen_recording/flutter_screen_recording.dart';
import 'package:video_player/video_player.dart';
import '../models/genre.dart';
import '../models/item.dart';
import 'home_screen.dart';

class VideoRecordScreen extends StatefulWidget {
  final Genre genre;
  final List<Item> items;

  const VideoRecordScreen({
    super.key,
    required this.genre,
    required this.items,
  });

  @override
  State<VideoRecordScreen> createState() => _VideoRecordScreenState();
}

class _VideoRecordScreenState extends State<VideoRecordScreen> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isCameraSupported = false;
  bool _isRecording = false;
  bool _hasStartedRecording = false;
  bool _showStartOverlay = true; // Show instructions before recording

  // Long press cancel state
  bool _isLongPressing = false;
  double _longPressProgress = 0.0;

  // Ranking state: rank -> item
  final Map<int, Item> _rankings = {};

  // Items to be placed (shuffled)
  late List<Item> _itemsToPlace;
  int _currentItemIndex = 0;

  // Get current item to place
  Item? get _currentItem => _currentItemIndex < _itemsToPlace.length
      ? _itemsToPlace[_currentItemIndex]
      : null;

  // Check if camera is supported on this platform
  bool get _isCameraSupportedPlatform {
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isAndroid;
  }

  @override
  void initState() {
    super.initState();
    // Shuffle and take only 10 items
    final List<Item> shuffled = List.from(widget.items)..shuffle();
    _itemsToPlace = shuffled.take(10).toList();
    _isCameraSupported = _isCameraSupportedPlatform;
    if (_isCameraSupported) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    if (!_isCameraSupported) return;

    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        // Find front camera
        final frontCamera = _cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras.first,
        );

        _cameraController = CameraController(
          frontCamera,
          ResolutionPreset.high,
          enableAudio: true,
        );

        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  void _dismissOverlayAndStart() {
    setState(() {
      _showStartOverlay = false;
    });
    // Start recording after overlay is dismissed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hasStartedRecording) {
        _startRecording();
      }
    });
  }

  Future<void> _startRecording() async {
    if (_isRecording || _hasStartedRecording) return;

    try {
      _hasStartedRecording = true;
      // Start native screen recording with audio
      final bool started =
          await FlutterScreenRecording.startRecordScreenAndAudio(
            'ranking_${DateTime.now().millisecondsSinceEpoch}',
          );
      if (started) {
        setState(() {
          _isRecording = true;
        });
      } else {
        debugPrint('Failed to start screen recording');
      }
    } catch (e) {
      debugPrint('Start recording error: $e');
    }
  }

  Future<String?> _stopRecording() async {
    if (!_isRecording) {
      return null;
    }

    try {
      setState(() {
        _isRecording = false;
      });

      // Stop screen recording and get the file path
      final String path = await FlutterScreenRecording.stopRecordScreen;
      debugPrint('Recording saved to: $path');
      return path;
    } catch (e) {
      debugPrint('Stop recording error: $e');
      return null;
    }
  }

  void _placeItemAtRank(int rank) {
    final item = _currentItem;
    if (item == null) return;

    // Check if rank is already taken
    if (_rankings.containsKey(rank)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$rank位は既に埋まっています'),
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }

    setState(() {
      _rankings[rank] = item;
      _currentItemIndex++;
    });
  }

  Future<void> _onComplete() async {
    // Stop recording and get video path
    final videoPath = await _stopRecording();

    if (!mounted) return;

    // Navigate to result screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => RecordingResultScreen(
          genre: widget.genre,
          rankings: Map.from(_rankings),
          videoPath: videoPath,
        ),
      ),
    );
  }

  void _startLongPressCancel() {
    setState(() {
      _isLongPressing = true;
      _longPressProgress = 0.0;
    });
    _animateLongPress();
  }

  void _animateLongPress() async {
    const totalDuration = 1500; // 1.5 seconds
    const updateInterval = 50; // Update every 50ms
    const steps = totalDuration ~/ updateInterval;

    for (int i = 0; i < steps; i++) {
      if (!_isLongPressing || !mounted) return;

      await Future.delayed(const Duration(milliseconds: updateInterval));

      if (!_isLongPressing || !mounted) return;

      setState(() {
        _longPressProgress = (i + 1) / steps;
      });
    }

    // Long press completed - cancel recording
    if (_isLongPressing && mounted) {
      _cancelRecording();
    }
  }

  void _cancelLongPress() {
    setState(() {
      _isLongPressing = false;
      _longPressProgress = 0.0;
    });
  }

  Future<void> _cancelRecording() async {
    // Stop recording without saving
    if (_isRecording) {
      try {
        await FlutterScreenRecording.stopRecordScreen;
      } catch (e) {
        debugPrint('Cancel recording error: $e');
      }
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if all items are placed
    final bool isComplete = _rankings.length == _itemsToPlace.length;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        // Double tap to finish recording (only when all items placed)
        onDoubleTap: isComplete ? _onComplete : null,
        // Long press to cancel recording
        onLongPressStart: (_) => _startLongPressCancel(),
        onLongPressEnd: (_) => _cancelLongPress(),
        onLongPressCancel: _cancelLongPress,
        child: Stack(
          children: [
            // Camera preview or placeholder
            if (_isCameraSupported &&
                _isCameraInitialized &&
                _cameraController != null)
              Positioned.fill(
                child: Transform.scale(
                  scaleX: -1, // Mirror for selfie mode
                  child: CameraPreview(_cameraController!),
                ),
              )
            else if (!_isCameraSupported)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        widget.genre.color.withAlpha(200),
                        widget.genre.color.withAlpha(100),
                      ],
                    ),
                  ),
                ),
              )
            else
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),

            // Bottom UI - all content here
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withAlpha(230),
                        Colors.black.withAlpha(180),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.7, 1.0],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 40, 12, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Current item display
                        if (_currentItem != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              color: widget.genre.color.withAlpha(40),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: widget.genre.color,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '${_currentItemIndex + 1} / ${_itemsToPlace.length}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _currentItem!.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  '↓ 順位をタップ',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 12),

                        // Ranking display (horizontal)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(100),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              // Header
                              Text(
                                '${widget.genre.emoji} ${widget.genre.name}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Rankings in 2 rows of 5
                              Row(
                                children: List.generate(5, (index) {
                                  final rank = index + 1;
                                  return Expanded(child: _buildRankItem(rank));
                                }),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: List.generate(5, (index) {
                                  final rank = index + 6;
                                  return Expanded(child: _buildRankItem(rank));
                                }),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Long press cancel overlay
            if (_isLongPressing)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withAlpha(180),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: _longPressProgress,
                            strokeWidth: 6,
                            color: Colors.red,
                            backgroundColor: Colors.white24,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'キャンセル中...',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '指を離すと中止',
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Start overlay with instructions
            if (_showStartOverlay)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _isCameraInitialized ? _dismissOverlayAndStart : null,
                  child: Container(
                    color: Colors.black.withAlpha(200),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.videocam,
                            color: widget.genre.color,
                            size: 64,
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            '撮影の流れ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            '① アイテムを順位にタップして配置',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '② 全て配置したら感想を話す',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                '③ ',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.genre.color.withAlpha(100),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'ダブルタップ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Text(
                                ' で撮影終了',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                '※ 画面を ',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withAlpha(100),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  '長押し',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Text(
                                ' でキャンセル',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: widget.genre.color,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              _isCameraInitialized ? 'タップして開始' : '準備中...',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankItem(int rank) {
    final item = _rankings[rank];
    final isFilled = item != null;
    final canTap = !isFilled && _currentItem != null;

    return GestureDetector(
      onTap: canTap ? () => _placeItemAtRank(rank) : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isFilled
              ? widget.genre.color.withAlpha(80)
              : canTap
              ? widget.genre.color.withAlpha(40)
              : Colors.white.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
          border: canTap
              ? Border.all(color: widget.genre.color, width: 1)
              : null,
        ),
        child: Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _getRankColor(rank),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item?.name ?? '---',
              style: TextStyle(
                color: canTap ? Colors.white : Colors.white70,
                fontSize: 9,
                fontWeight: isFilled ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.grey.shade600;
    }
  }
}

// Result screen after recording
class RecordingResultScreen extends StatefulWidget {
  final Genre genre;
  final Map<int, Item> rankings;
  final String? videoPath;

  const RecordingResultScreen({
    super.key,
    required this.genre,
    required this.rankings,
    this.videoPath,
  });

  @override
  State<RecordingResultScreen> createState() => _RecordingResultScreenState();
}

class _RecordingResultScreenState extends State<RecordingResultScreen> {
  bool _isSaving = false;
  bool _isSaved = false;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initVideoPlayer();
  }

  Future<void> _initVideoPlayer() async {
    if (widget.videoPath == null) return;

    final file = File(widget.videoPath!);
    if (!await file.exists()) return;

    _videoController = VideoPlayerController.file(file);
    try {
      await _videoController!.initialize();
      // Add listener to update UI when video state changes
      _videoController!.addListener(_onVideoStateChanged);
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Video init error: $e');
    }
  }

  void _onVideoStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _videoController?.removeListener(_onVideoStateChanged);
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _saveVideo() async {
    if (widget.videoPath == null || _isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      debugPrint('Saving video from path: ${widget.videoPath}');

      // Verify file exists
      final file = File(widget.videoPath!);
      if (!await file.exists()) {
        throw Exception('ファイルが見つかりません');
      }

      // Save to camera roll
      await Gal.putVideo(widget.videoPath!);

      if (mounted) {
        setState(() {
          _isSaving = false;
          _isSaved = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('カメラロールに保存しました！'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Save error: $e');
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('保存に失敗しました: $e')));
      }
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          SizedBox(height: 8),
          // Video player area - expanded to fill screen
          Expanded(
            child: widget.videoPath != null
                ? Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _isVideoInitialized && _videoController != null
                        ? Column(
                            children: [
                              SizedBox(height: 8),
                              // Video player
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (_videoController!.value.isPlaying) {
                                        _videoController!.pause();
                                      } else {
                                        _videoController!.play();
                                      }
                                    });
                                  },
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Center(
                                        child: AspectRatio(
                                          aspectRatio: _videoController!
                                              .value
                                              .aspectRatio,
                                          child: VideoPlayer(_videoController!),
                                        ),
                                      ),
                                      // Play/pause overlay
                                      if (!_videoController!.value.isPlaying)
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black.withAlpha(100),
                                            shape: BoxShape.circle,
                                          ),
                                          padding: const EdgeInsets.all(16),
                                          child: const Icon(
                                            Icons.play_arrow,
                                            color: Colors.white,
                                            size: 48,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              // Video controls
                              Container(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    // Progress bar
                                    VideoProgressIndicator(
                                      _videoController!,
                                      allowScrubbing: true,
                                      colors: VideoProgressColors(
                                        playedColor: widget.genre.color,
                                        bufferedColor: widget.genre.color
                                            .withAlpha(100),
                                        backgroundColor: Colors.white24,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Control buttons
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Replay button
                                        IconButton(
                                          onPressed: () async {
                                            await _videoController!.seekTo(
                                              Duration.zero,
                                            );
                                            await _videoController!.play();
                                          },
                                          icon: const Icon(
                                            Icons.replay,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Play/Pause button
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              if (_videoController!
                                                  .value
                                                  .isPlaying) {
                                                _videoController!.pause();
                                              } else {
                                                _videoController!.play();
                                              }
                                            });
                                          },
                                          icon: Icon(
                                            _videoController!.value.isPlaying
                                                ? Icons.pause
                                                : Icons.play_arrow,
                                            color: Colors.white,
                                            size: 32,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Duration text
                                        ValueListenableBuilder(
                                          valueListenable: _videoController!,
                                          builder: (context, value, child) {
                                            final position = value.position;
                                            final duration = value.duration;
                                            return Text(
                                              '${_formatDuration(position)} / ${_formatDuration(duration)}',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white54,
                            ),
                          ),
                  )
                : const Center(
                    child: Text(
                      '動画がありません',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
          ),

          // Bottom buttons
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Save video button
                  if (widget.videoPath != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isSaving || _isSaved ? null : _saveVideo,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(_isSaved ? Icons.check : Icons.download),
                        label: Text(
                          _isSaving
                              ? '保存中...'
                              : _isSaved
                              ? '保存済み'
                              : '動画を保存',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isSaved
                              ? Colors.green
                              : widget.genre.color,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.green,
                          disabledForegroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  if (widget.videoPath != null) const SizedBox(width: 12),
                  // Home button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.home),
                      label: const Text('ホームへ'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

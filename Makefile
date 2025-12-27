.PHONY: build-ipa

build-ipa:
	cd ranking_challenge && flutter build ipa --release
	open ranking_challenge/build/ios/archive/Runner.xcarchive

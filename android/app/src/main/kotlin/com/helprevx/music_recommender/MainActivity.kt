package com.helprevx.music_recommender

import com.ryanheise.audioservice.AudioServiceActivity

// Extends AudioServiceActivity (not FlutterActivity) so audio_service can host the
// background media session correctly. See:
// https://pub.dev/packages/audio_service#android-setup
class MainActivity : AudioServiceActivity()

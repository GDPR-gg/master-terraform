//
// Copyright 2019 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

struct ApplicationConstants {
  static let TTS_Host = "texttospeech.googleapis.com"
  // TODO: Replace with your GCP PROJECT_ID
  static let translateParent = "projects/project_id/locations/global"
  static let languageCode = "en-US"
  static let STT_Host = "speech.googleapis.com"
  static let TRANSLATE_Host = "translation.googleapis.com"
}

extension ApplicationConstants {
  static let ttsScreenTitle = "Speech-to-Speech Translation"
  static let SpeechScreenTitle = "Speech-to-Speech Translation"
  static let SettingsScreenTtitle = "Settings"
  static let selfKey = "Self"
  static let botKey = "Bot"
  static let selectedTransFrom = "selectedTransFrom"
  static let selectedTransTo = "selectedTransTo"
  static let selectedVoiceType = "selectedVoiceType"
  static let selectedSynthName = "selectedSynthName"
  static let useerLanguagePreferences = "useerLanguagePreferences"
  static let translateFromPlaceholder = "Translate from"
  static let translateToPlaceholder = "Translate to"
  static let synthNamePlaceholder = "TTS Tech"
  static let voiceTypePlaceholder = "Voice type"

}

//MARK: Token service constants
extension ApplicationConstants {
  static let token = "Token"
  static let accessToken = "accessToken"
  static let expireTime = "expireTime"
  static let tokenReceived = "tokenReceived"
  static let retreivingToken = "RetrievingToken"
  static let getTokenAPI = "getOAuthToken"
  static let tokenType = "Bearer "
  static let noTokenError = "No token is available"
  static let tokenFetchingAlertTitle = "Alert"
  static let tokenFetchingAlertMessage = "Retrieving token ..."
}


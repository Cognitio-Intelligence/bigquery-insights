# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Contains cloud authentication related functionality."""

import logging
import webbrowser
from typing import List
from urllib import parse

BASE_URL = 'https://www.gstatic.com/bigquerydatatransfer/oauthz/auth'
REDIRECT_URI = 'urn:ietf:wg:oauth:2.0:oob'


def retrieve_authorization_code(client_id: str, scopes: List[str],
                                app_name: str):
    """Returns authorization code.

    Args:
        client_id: The client id.
        scopes: The list of scopes.
        app_name: Name of the app.
    """
    scopes_str = ' '.join(scopes)
    authorization_code_request = {
        'client_id': client_id,
        'scope': scopes_str,
        'redirect_uri': REDIRECT_URI,
        'response_type': 'code',
        'access_type': 'offline'
    }

    encoded_request = parse.urlencode(
        authorization_code_request, quote_via=parse.quote)
    url = f'{BASE_URL}?{encoded_request}'
    
    print(f"\nOpening browser for {app_name} authorization...")
    print(f"If the browser doesn't open automatically, please visit this URL:\n{url}\n")
    
    try:
        # Try to open the browser automatically
        webbrowser.open(url)
    except Exception as e:
        print(f"Could not open browser automatically: {str(e)}")
        print("Please copy and paste the URL into your browser manually.")

    return input('Please paste the authorization code here: ')
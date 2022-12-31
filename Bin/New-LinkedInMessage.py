# --------------------------------------------------------------------------
# https://www.jcchouinard.com/get-your-oauth-credentials-for-linkedin-api/
# https://www.jcchouinard.com/authenticate-to-linkedin-api-using-oauth2/
# --------------------------------------------------------------------------

import requests

from ln_oauth import auth, headers

CREDENTIALS = 'credentials.json'
#
# client_id
# client_secret
# redirected_uri
# access_token
#
access_token = auth(CREDENTIALS) # Authenticate the API
headers = headers(access_token) # Make the headers to attach to the API call.

def user_info(headers):
    '''
    Get user information from Linkedin
    '''
    response = requests.get('https://api.linkedin.com/v2/me', headers = headers)
    user_info = response.json()
    return user_info

# Get user id to make a UGC post
user_info = user_info(headers)
urn = user_info['id']

# UGC will replace shares over time.
API_URL = 'https://api.linkedin.com/v2/ugcPosts'
author = f'urn:li:person:{urn}'

MESSAGE = '''
Interested to automate LinkedIn using #Python and the LinkedIn API? 
Read this in-depth Python for #SEO post by Jean-Christophe Chouinard.
I just made this post using the LinkedIn API. Next step is to translate it to #PowerShell.
'''
LINK = 'https://www.jcchouinard.com/how-to-post-on-linkedin-api-with-python/'
LINK_TEXT = 'Complete tutorial using the LinkedIn API'

post_data = {
    "author": author,
        "lifecycleState": "PUBLISHED",
        "specificContent": {
            "com.linkedin.ugc.ShareContent": {
                "shareCommentary": {
                    "text": MESSAGE
                },
                "shareMediaCategory": "ARTICLE",
                "media": [
                    {
                        "status": "READY",
                        "description": {
                            "text": MESSAGE
                        },
                        "originalUrl": LINK,
                        "title": {
                            "text": LINK_TEXT
                        }
                    }
                ]
            }
        },
        "visibility": {
            "com.linkedin.ugc.MemberNetworkVisibility": "CONNECTIONS"
        }
    }

if __name__ == '__main__':
    r = requests.post(API_URL, headers=headers, json=post_data)
    r.json()

from __future__ import print_function
import httplib2
import os
import webbrowser
import time
import csv

from apiclient import discovery
from oauth2client.client import flow_from_clientsecrets
from oauth2client import tools
from apiclient import errors

try:
    import argparse
    flags = argparse.ArgumentParser(parents=[tools.argparser]).parse_args()
except ImportError:
    flags = None

# gen_uuid = lambda : str(uuid.uuid4()) # get random UUID string, not used now

# If modifying these scopes, delete your previously saved credentials
# at ~/.credentials/slides.googleapis.com-python-quickstart.json
SCOPES = 'https://www.googleapis.com/auth/presentations https://www.googleapis.com/auth/drive'
CLIENT_SECRET_FILE = 'client_secret.json'
APPLICATION_NAME = 'Build Slides API'

# The "flow" is specific to the OAuth2 client and detailed on the Google
# APIs website
src_dir = os.path.dirname(os.path.abspath(__file__))
flow = flow_from_clientsecrets(os.path.join(src_dir, 'client_secret.json'),
                               scope = SCOPES,
                               redirect_uri= 'urn:ietf:wg:oauth:2.0:oob')
auth_uri = flow.step1_get_authorize_url()
webbrowser.open_new(auth_uri)

auth_code = ""

# Asks user to give the authentication code which opens in browser
while len(auth_code) == 0:
    auth_code = raw_input("Enter authorization code: ")

credentials = flow.step2_exchange(auth_code)

http_auth = credentials.authorize(httplib2.Http())
drive_service = discovery.build('drive', 'v3', http=http_auth)
slide_service = discovery.build('slides', 'v1', http=http_auth)


def copy_presentation(service, origin_file_id, copy_title):
  """Copy an existing file.

  Args:
    service: Drive API service instance.
    origin_file_id: ID of the origin file to copy.
    copy_title: Title of the copy.

  Returns:
    The copied file if successful, None otherwise.
  """
  body = {
      'name' : copy_title
  }
  try:
    return service.files().copy(
        fileId=origin_file_id, body=body).execute()
  except errors.HttpError as error:
    print('An error occurred: %s' % error)
  return None


template_presentation = '1Zxc2mO_FT5sAHCK8vSnWkVUtoIldVqTdG4kT-OFKc5w'

print("** Copying presentation")

# copies the template presentation
deck_title = 'DQC_Rule_Results_' + time.strftime("%Y-%m-%d")
drive_response = copy_presentation(drive_service, template_presentation,
                                   deck_title)
presentation_copy_id = drive_response.get('id')

# grabs the newly copied presentation
presentation = slide_service.presentations().get(
    presentationId=presentation_copy_id).execute()
slides = presentation.get('slides')

# gets the deck and titleSlide IDs from the presentation
deckID = presentation['presentationId']
titleSlide = presentation['slides'][0]

print("** Uploading temp images")

# temporarily upload image to google_drive from local copy
project_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
plot_dir=os.path.join(project_dir, 'plots')
image_paths = [
    os.path.join(plot_dir, 'rule_violations_all_all_per1k_stack.png'),
    os.path.join(plot_dir, 'rule_violations_laf_all_per1k_stack.png'),
    os.path.join(plot_dir, 'rule_violations_src_all_per1k_stack.png'),
    os.path.join(plot_dir, 'rule_violations_all_no15_no01_per1k_stack.png'),
    os.path.join(plot_dir, 'rule_violations_laf_no15_no01_per1k_stack.png'),
    os.path.join(plot_dir, 'rule_violations_src_no15_no01_per1k_stack.png')
    ]

table_paths = [
    os.path.join(plot_dir, 'rule_violations_table_all.csv'),
    os.path.join(plot_dir, 'rule_violations_table_laf.csv'),
    os.path.join(plot_dir, 'rule_violations_table_src.csv'),
    os.path.join(plot_dir, 'unique_dp_counts.csv'),
]

file_ids = []
image_urls = []
for i in range(len(image_paths)):
    upload = drive_service.files().create(
        body={'name': 'rule_violations_all_all_per1k_stack',
              'mimeType': 'image/png'},
        media_body=image_paths[i]).execute()
    file_ids.append(upload.get('id'))
    # need image url for inserting into slide
    image_url = '%s&access_token=%s' % (
        drive_service.files().get_media(fileId=file_ids[i]).uri,
        credentials.access_token)
    image_urls.append(image_url)


print("** Reading in table data")

tbl_data = []
for i in range(len(table_paths)):
    dr = csv.reader(open(table_paths[i], 'rb'))
    years = []
    for line in dr:
        years.append(line)

    years = years[1:9]

    for year in years:
        for i in range(1, len(year)):
            year[i] = '{:,}'.format(int(year[i]))

    tbl_data.append(years)

# tableSlide = presentation['slides'][8]
# try:
#     # parsed = json.loads(titleSlide)
#     print(json.dumps(tableSlide, indent=4, sort_keys=True))
# except:
#     print("couldn't print that junk")

# puts image slides into an array
image_slides = []
for i in range(2, 8):
    image_slides.append(presentation['slides'][i])

print("** Identifying image and table locations")

# loop over the image slides, an get object id for the rectangle in each slide
obj_rect = []
for i in range(2, 8):
    for obj in presentation['slides'][i]['pageElements']:
        if obj['shape']['shapeType'] == 'RECTANGLE':
            obj_rect.append(obj)


# same as above for the table slides
table_slides = []
for i in range(8, 12):
    table_slides.append(presentation['slides'][i])

obj_tbl = []
for i in range(8, 12):
    for obj in presentation['slides'][i]['pageElements']:
        if 'table' in obj:
            obj_tbl.append(obj)

# grabs the subtitle
subtitleID = titleSlide['pageElements'][1]['objectId']
# Subtitle will be replaced with current date
current_date = time.strftime("%B %d, %Y")

# requests according to the api format.  Pretty print json of a slides object
# to get a better idea of what is in each object
reqs = [
    # {'replaceAllText': {'findText': 'current_date',
    #  'replaceText': current_date}}
    {'deleteText': {'objectId': subtitleID}},
    {'insertText': {'objectId': subtitleID, 'text': current_date}},
    {'createImage': {
        'url': image_urls[0],
        'elementProperties': {
            'pageObjectId': image_slides[0]['objectId'],
            'size': {
                'height': {
                    'magnitude': obj_rect[0]['size']['height']['magnitude'],
                    'unit': obj_rect[0]['size']['height']['unit']
                },
                'width': obj_rect[0]['size']['width']
            },
            'transform': {
                'scaleX': obj_rect[0]['transform']['scaleX'],
                'scaleY': obj_rect[0]['transform']['scaleY']*2.5,
                'translateX': obj_rect[0]['transform']['translateX'],
                'translateY': -850000,  # obj_rect[0]['transform']['translateY']*0.33,
                'unit': obj_rect[0]['transform']['unit']
            }
        }
    }},
    {'deleteObject': {'objectId': obj_rect[0]['objectId']}},
    {'createImage': {
            'url': image_urls[1],
            'elementProperties': {
                'pageObjectId': image_slides[1]['objectId'],
                'size': {
                    'height': {
                        'magnitude': obj_rect[1]['size']['height']['magnitude'],
                        'unit': obj_rect[1]['size']['height']['unit']
                    },
                    'width': obj_rect[1]['size']['width']
                },
                'transform': {
                    'scaleX': obj_rect[1]['transform']['scaleX'],
                    'scaleY': obj_rect[1]['transform']['scaleY']*2.5,
                    'translateX': obj_rect[1]['transform']['translateX'],
                    'translateY': -850000, # obj_rect[0]['transform']['translateY']*0.33,
                    'unit': obj_rect[1]['transform']['unit']
                }
            }
        }},
        {'deleteObject': {'objectId': obj_rect[1]['objectId']}},
    {'createImage': {
        'url': image_urls[2],
        'elementProperties': {
            'pageObjectId': image_slides[2]['objectId'],
            'size': {
                'height': {
                    'magnitude': obj_rect[2]['size']['height']['magnitude'],
                    'unit': obj_rect[2]['size']['height']['unit']
                },
                'width': obj_rect[2]['size']['width']
            },
            'transform': {
                'scaleX': obj_rect[2]['transform']['scaleX'],
                'scaleY': obj_rect[2]['transform']['scaleY'] * 2.5,
                'translateX': obj_rect[2]['transform']['translateX'],
                'translateY': -850000,
            # obj_rect[0]['transform']['translateY']*0.33,
                'unit': obj_rect[2]['transform']['unit']
            }
        }
    }},
    {'deleteObject': {'objectId': obj_rect[2]['objectId']}},
    {'createImage': {
        'url': image_urls[3],
        'elementProperties': {
            'pageObjectId': image_slides[3]['objectId'],
            'size': {
                'height': {
                    'magnitude': obj_rect[3]['size']['height']['magnitude'],
                    'unit': obj_rect[3]['size']['height']['unit']
                },
                'width': obj_rect[3]['size']['width']
            },
            'transform': {
                'scaleX': obj_rect[3]['transform']['scaleX'],
                'scaleY': obj_rect[3]['transform']['scaleY'] * 2.5,
                'translateX': obj_rect[3]['transform']['translateX'],
                'translateY': -850000,
            # obj_rect[0]['transform']['translateY']*0.33,
                'unit': obj_rect[3]['transform']['unit']
            }
        }
    }},
    {'deleteObject': {'objectId': obj_rect[3]['objectId']}},
    {'createImage': {
        'url': image_urls[4],
        'elementProperties': {
            'pageObjectId': image_slides[4]['objectId'],
            'size': {
                'height': {
                    'magnitude': obj_rect[4]['size']['height']['magnitude'],
                    'unit': obj_rect[4]['size']['height']['unit']
                },
                'width': obj_rect[4]['size']['width']
            },
            'transform': {
                'scaleX': obj_rect[4]['transform']['scaleX'],
                'scaleY': obj_rect[4]['transform']['scaleY'] * 2.5,
                'translateX': obj_rect[4]['transform']['translateX'],
                'translateY': -850000,
            # obj_rect[0]['transform']['translateY']*0.33,
                'unit': obj_rect[4]['transform']['unit']
            }
        }
    }},
    {'deleteObject': {'objectId': obj_rect[4]['objectId']}},
    {'createImage': {
        'url': image_urls[5],
        'elementProperties': {
            'pageObjectId': image_slides[5]['objectId'],
            'size': {
                'height': {
                    'magnitude': obj_rect[5]['size']['height']['magnitude'],
                    'unit': obj_rect[5]['size']['height']['unit']
                },
                'width': obj_rect[5]['size']['width']
            },
            'transform': {
                'scaleX': obj_rect[5]['transform']['scaleX'],
                'scaleY': obj_rect[5]['transform']['scaleY'] * 2.5,
                'translateX': obj_rect[5]['transform']['translateX'],
                'translateY': -850000,
            # obj_rect[0]['transform']['translateY']*0.33,
                'unit': obj_rect[5]['transform']['unit']
            }
        }
    }},
    {'deleteObject': {'objectId': obj_rect[5]['objectId']}},
]
# use a list comprehension for updating the text in each table object, for the
# four tables in the slide deck
reqs.extend([
    {'insertText': {
        'objectId': obj_tbl[0]['objectId'],
        'cellLocation': {'rowIndex': i+1, 'columnIndex': j},
        'text': str(data),
    }} for i, year in enumerate(tbl_data[0]) for j, data in enumerate(year)]
)

reqs.extend([
    {'insertText': {
        'objectId': obj_tbl[1]['objectId'],
        'cellLocation': {'rowIndex': i+1, 'columnIndex': j},
        'text': str(data),
    }} for i, year in enumerate(tbl_data[1]) for j, data in enumerate(year)]
)

reqs.extend([
    {'insertText': {
        'objectId': obj_tbl[2]['objectId'],
        'cellLocation': {'rowIndex': i+1, 'columnIndex': j},
        'text': str(data),
    }} for i, year in enumerate(tbl_data[2]) for j, data in enumerate(year)]
)

reqs.extend([
    {'insertText': {
        'objectId': obj_tbl[3]['objectId'],
        'cellLocation': {'rowIndex': i+1, 'columnIndex': j},
        'text': str(data),
    }} for i, year in enumerate(tbl_data[3]) for j, data in enumerate(year)]
)

print("** Updating presentation")

# send requests to the API
slide_service.presentations().batchUpdate(
    body={'requests': reqs},
    presentationId=presentation_copy_id).execute()

print("** Deleting temp images from Drive")

# delete the temp images that were previously uploaded to the drive API
for id in file_ids:
    try:
        drive_service.files().delete(fileId=id).execute()
    except:
        print("Temp images may not have been deleted from Drive")

print('** DONE')
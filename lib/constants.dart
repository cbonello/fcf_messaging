const String APP_NAME = 'FCF Messaging';
const String APP_COPYRIGHT = '©2020, C. Bonello';
const String APP_ASSET_LOGO = 'assets/images/app_logo.png';

const int MIN_PASSWORD_LENGTH = 8;
const double MIN_PASSWORD_STRENGTH = 0.5;

const Duration DEFAULT_NETWORK_TIMEOUT = Duration(seconds: 15);
const Duration DEFAULT_MESSAGE_SEND_TIMEOUT = Duration(seconds: 5);

const String DATE_FORMAT_MONTH = 'MMM d';
const String DATE_FORMAT_TIME = 'H:mm a';
const String DATE_FORMAT = '$DATE_FORMAT_MONTH, $DATE_FORMAT_TIME';

const int MAX_CHATS = 128;
const int MAX_CONTACTS = 256;

// Cloud Firestore.
const String USERS_PATH = 'users';
const String CONTACTS_PATH = 'contacts';
const String CHATS_PATH = 'chats';
const String MESSAGES_PATH = 'messages';

// Cloud storage for firebase.
const String AVATAR_FOLDER = 'avatars';
const String CHATS_FOLDER = 'chats';
const String IMAGES_FOLDER = 'images';

const int ADMIN_ROLE = 1;
const int USER_ROLE = 2;

const int MESSAGES_LOAD_LIMIT = 20;

const int MESSAGE_TEXT_TYPE = 1;
const int MESSAGE_IMAGE_TYPE = 2;

const String DEFAULT_STATUS = 'Hey there! I am using $APP_NAME';

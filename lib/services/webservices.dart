class WebServices {
//  static final String HOST_URL = "http://leanports.com/muemue/api/web/";
 // static final String HOST_URL = "http://testendpoint.tellmelive.com/muemue/api/web/"; //==testing
  static final String HOST_URL = "http://endpoint.tellmelive.com/muemue/api/web/";//==Publice
 // static final String CHAT_SERVER = "http://testchat.tellmelive.com/"; //=== testing
  static final String CHAT_SERVER = "http://chat.tellmelive.com/"; //=== Public



  /*
  static final String DefaultIP     = HOST_URL + "api/getDefaultLocation";

  */


  static final String DefaultIP = HOST_URL + "user/default-ip";
  static final String ValidePhoneNumber = HOST_URL + "user/check-mobile";

  static final String ValidEmail = HOST_URL + "user/check-mail";

  static final String UploadImages = HOST_URL + "user/registration";

  static final String GetMyDetails = HOST_URL + "user/get-my-det?token=";


  static final String ToggleLocation = HOST_URL + "user/toggle-location?token=";

  static final String LoginMobile = HOST_URL + "user/login-from-mobile";

  static final String OtpMobile = HOST_URL + "user/check-otp-authentication";

  static final String LoginFacebook = HOST_URL + "user/fb-access";

  static final String RegisterByFacebook = HOST_URL + "user/fb-registration";

  static final String GetInerest = HOST_URL + "user/get-having-interest?token=";

  static final String UpdateInterest =
      HOST_URL + "user/update-having-interest?token=";

  static final String UpdateProfessional =
      HOST_URL + "user/update-prof-interest?token=";

  static final String GetProfessional =
      HOST_URL + "user/get-prof-interest?token=";

  static final String GetActivity = HOST_URL + "user/get-activity?token=";

  static final String UpdateActivity = HOST_URL + "user/update-activity?token=";

  static final UpdateUserLocation = HOST_URL + "user/update-gps-info?token=";

  static final GetPeople = HOST_URL + "chat/user?token=";

  static final GetProfessionalUser = HOST_URL + "chat/professional?token=";


  static final GetChatUserDetail = HOST_URL + "chat/subscrib-user?token=";

  static final GetChatUserLike = HOST_URL + "chat/send-accept-invitation?token=";

  static final GetUserUnLike = HOST_URL + "chat/unlike?token=";

  static final CreateEvent = HOST_URL + "events/add?token=";

  static final GetCreateEvent = HOST_URL + "events/info?token=";

  static final GetMessage =  HOST_URL + "events/addchat?token=" ;            

  static final GetMessageshow = HOST_URL + "events/chat?token=" ;     

  static final GetEventByUser = HOST_URL + "events/get-one?token=";

  static final GetUserActivity = HOST_URL + "events/access?token=";

  static final GetSubscribe = HOST_URL + "events/subscribe?token=";

  static final GetActivityWall = HOST_URL + "events/get-wall?token=";

  static final GetUserProfile = HOST_URL + "chat/info?token=";

  static final GetActivityDelete = HOST_URL + "events/delete?token=";

  static final GetProfile = HOST_URL + "user/info?token=";

  static final GetUpdateDOB = HOST_URL + "user/update-dob?token=";

  static final GetUpdateGender = HOST_URL + "user/update-gender?token=";

  static final GetDeleteImage = HOST_URL + "user/delete-image?token=";

  static final SaveAbout  = HOST_URL + "user/about?token=";




  static final GetUpdateImage = HOST_URL + "user/updateimage2?token=";

  static final GetChatUser = HOST_URL + "chat/access-user?token=";

  static final GetUserPrefrence = HOST_URL + "user/preference?token=";

  static final GetUpdatePrefrence = HOST_URL + "user/update-preference?token=";

  static final GetFavorite = HOST_URL + "chat/favorite?token=";

  // static final GetDeleteFavorite = HOST_URL + "chat/remove-favorite?token=";

  static final GetMiu = HOST_URL + "chat/meu?token=";

  static final GetMatchProfile = HOST_URL + "chat/matched?token=";

  static final GetNotification = HOST_URL + "user/notification?token=";

  static final GetCatgroy = HOST_URL + "events/catetory?token=";

  static final GetIgnore = HOST_URL + "chat/ignore?token=";

  static final GetUpdateName = HOST_URL +"user/update-profile?token=";

  static final UpdateSocialMedia = HOST_URL + "user/socialupdate?token=";

  static final GetUserLike = HOST_URL + "chat/like?token=";

  static final GetVisitor = HOST_URL + "chat/visitor?token=";

  static final GetDeletedAccount = HOST_URL + "user/delete?token=";

  static final GetDeactivate = HOST_URL + "user/deactivate?token=";

  static final GetAppKey = HOST_URL + "user/appkey?token=";

  static final GetBlockUser = HOST_URL + "chat/block?token=";
  static final GetReportBlockUser = HOST_URL + "chat/reportblock?token=";

  static final GetUnBlockUser = HOST_URL + "chat/unblock?token=";
  static final GetAllChatClearUser = HOST_URL + "chat/delete-chat?token=";



}

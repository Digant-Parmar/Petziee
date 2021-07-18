// @dart=2.9
import 'package:shared_preferences/shared_preferences.dart';

class PhoneDatabase{

  static String sharePreferenceUserLoggedInKey = "ISLOGGEDIN";


  static String sharePreferenceUserNameKey = "USERNAME";
  static String sharePreferenceProfileNameKey = "PROFILENAME";
  static String sharePreferenceBioKey = "BIO";
  static String drawingCountKey = "dCount";
  static String textCountKey = "tCount";
  static String filePathKey = "FILEPATH";
  static String isOpenKey = "ISOPEN";
  static String isPermissionGiven = "Permission";
  static String sharePreferencePhoneNumber = "PHONENUMBER";
  static String sharePreferenceVerificationId = "VID";
  static String mapTypeCheckBoxList = "MAPCHECKBOXLIST";
  static String isPrivateAccount = "PRIVATEACCOUNT";
  static String isUploadInProgress = "ISUPLOADING";
  static String mapIcons = "MAPICONS";
  static String currentUserMapIcon = "CURRENTMAPICON";
  static String appTheme = "APPTHEME";

  // static String currentPage = "CURRENT_PAGE";







//Saving the data to Shared Preferences

  static Future<void>saveAppTheme(String currentAppTheme) async{
    //Verification Id
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(appTheme, currentAppTheme);
  }

  static Future<void>saveVID(String vid) async{
    //Verification Id
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(sharePreferenceVerificationId, vid);
  }

  static Future<void>saveIsPrivateAccount(bool isPrivate) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(isPrivateAccount, isPrivate);
  }

  static Future<void>saveMapIcons(String mapIconName) async{
    //Current Map Icon
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(mapIcons, mapIconName);
  }
  static Future<void>saveCurrentUserMapIcon(String mapIconName) async{
    //Current Map Icon
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(currentUserMapIcon, mapIconName);
  }
  static Future<void>saveMapTypeCheckBoxList(List<String> checkboxList) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setStringList(mapTypeCheckBoxList, checkboxList);
  }


  static Future<void>saveUserLoggedInSharedPreference(bool isUserLoggedIn) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(sharePreferenceUserLoggedInKey, isUserLoggedIn);
  }

  static Future<void>saveUserNameSharedPreference(String userName) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(sharePreferenceUserNameKey, userName);
  }

  static Future<void>saveProfileNameSharedPreference(String profileName) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(sharePreferenceProfileNameKey, profileName);
  }

  static Future<void>saveBioSharedPreference(String bio) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(sharePreferenceBioKey, bio);
  }

  static Future<void>saveDrawingImageCounter(int i) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setInt(drawingCountKey, i);
  }

  static Future<void>saveTextImageCounter(int i) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setInt(textCountKey, i);
  }

  static Future<void>saveFilePath(String filePath) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(filePathKey, filePath);
  }

  static Future<void>saveMapSettingIsOpenState(bool isOpen) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(isOpenKey, isOpen);
  }


  static Future<void>saveIsPermissionGiven(bool isGiven) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(isPermissionGiven, isGiven);
  }

  static Future<void>savePhonenumber(String phonenumber) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(sharePreferencePhoneNumber, phonenumber);
  }
  static Future<void>saveIsUploading(bool isUploading) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(isUploadInProgress,isUploading);

  }

  // static Future<void>saveCurrentPage(List<String> list) async{
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   return await prefs.setStringList(currentPage, list);
  // }

  //getting data form Shared Preferences


  static Future<String>getAppTheme() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return  prefs.getString(appTheme);
  }


  static Future<bool>getUserLoggedInSharedPreference() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return  prefs.getBool(sharePreferenceUserLoggedInKey);
  }

  static Future<String>getPhoneNumber() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return  prefs.getString(sharePreferencePhoneNumber);
  }

  static Future<String>getUserNameSharedPreference() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return  prefs.getString(sharePreferenceUserNameKey);
  }
  static Future<String>getProfileNameSharedPreference() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return  prefs.getString(sharePreferenceProfileNameKey);
  }

  static Future<String>getBioSharedPreference() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return  prefs.getString(sharePreferenceBioKey);
  }

  static Future<int>getDrawingImageCounter() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(drawingCountKey);
  }

  static Future<int>getTextImageCounter() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(textCountKey);
  }

  static Future<String>getFilePath(String filePath) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(filePathKey);
  }

  static Future<bool>getMapSettingIsOpneState() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return  prefs.getBool(isOpenKey);
  }

  static Future<bool>getIsPermissionGiven() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return  prefs.getBool(isPermissionGiven);
  }


  static Future<String>getVID() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(sharePreferenceVerificationId);
  }
  static Future<List<String>>getMapTypeCheckBocList() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(mapTypeCheckBoxList);
  }


  static Future<bool>getIsPrivateAccount() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return  prefs.getBool(isPrivateAccount);
  }

  static Future<bool>getIsUploading() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return  prefs.getBool(isUploadInProgress);
  }

  static Future<String>getMapIcons() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(mapIcons);
  }
  static Future<String>getCurrentUserMapIcon() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(currentUserMapIcon);
  }

}
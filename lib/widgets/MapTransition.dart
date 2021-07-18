// @dart=2.9

String profileId;
bool isOpen;

updateMapUser({String userId, bool checkOpen})async{
  profileId = userId;
  isOpen = checkOpen;
}

removeMapUser(){
  profileId = null;
  isOpen = null;
}
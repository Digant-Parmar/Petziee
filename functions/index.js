const functions = require("firebase-functions");
const admin = require("firebase-admin");
const moment = require('moment');

admin.initializeApp();
const spawn = require('child-process-promise').spawn;

//{
//    "test":{
//        "testId":{
//            "testField": "v"
//        }
//    }
//
//}
//




exports.getCircularCroppedImage = functions.https.onCall(async(req,res)=>{
    console.log(req.path);
    const file = admin.storage().bucket().file(req.path);
    const tempPath = `/tmp/${req.name}`;
    try{
        await file.download({destination: tempPath});
        console.log(`Downloaded ${file.name} to ${tempPath}.`);
    }catch(err){
        throw new Error(`File download failed: ${err}`);
    }

    await spawn('convert', [
        tempPath,
        '-resize', '250x250',
        '-background', 'none',
        '-vignette', '0x0+0+0',
        tempPath
    ]);

    await admin.storage().bucket().upload(tempPath,{destination: req.path,metadata:{contentType: 'image/png'}});

    return 'Uploaded';

});


exports.onUserStatusChange = functions.database
        .ref("/{uid}/isOnline")
        .onUpdate(async (change, context)=>{
            //Get the data written to RealTime Database
            const isOnline = change.after.val();

            //Get a reference to the firestore document
            const userStatusFirestoreRef = admin.firestore().doc(`users/${context.params.uid}`);

            console.log('status: ${isOnline}');

            //Update the value on the Firestore

            return userStatusFirestoreRef.update({
                isOnline: isOnline,
                lastOnline:Date.now(),
            });

        });

        exports.test = functions.firestore
            .document("/test/{testId}")
            .onUpdate(async (snapshot, context)=> {
                 const token ="dtdsN4VQSfG3hEWeGYK1Iw:APA91bHzw_9uV5v1tAdDUfbxipaZWI7EtChunRpvpl9tPrOSt28-9dCz3WaPk7QTCio3w7huPb43QZvdSJFvh_Hxw-cOd8NBgAt4PdikkcJGOXh7EXgdTCLb68kp-eZAICu_myWTwH7E";
                  // const resource = context.resource;
                   const payload = {
                        data: {
                            title: "I sent this message",
                            body:  "This message was sent by me",
                            notificationType: "COMMENT",
                            imageUrl :"https://firebasestorage.googleapis.com/v0/b/petezzie.appspot.com/o/FCMImages%2Fcimage.png?alt=media&token=34db55ef-197a-4c5d-9853-7abce12370c4",

                        }
                    };
                  await admin.messaging().sendToDevice(token, payload);
            });

// const token ="fsct48BHRp6k5qemTW6spl:APA91bGnIwpo0vsWNP_3OdsXD5N4miq7QIqsIh-l8Cq9DS40I8is1FYXAXvTZ7BcczrXwkbT_vhFKVOKZfj5--V-qhKKJXF-fC6HZRF0Y4WNfXYcMGGWWwIYZkBorIksp7UPKmdUXhAe";
//  // const resource = context.resource;
//   const payload = {
//        notification: {
//            title: "I sent this message",
//            icon: "https://firebasestorage.googleapis.com/v0/b/petezzie.appspot.com/o/FCMImages%2Fim.jpg?alt=media&token=47fe5381-f41c-4966-93dd-be91f56cc35f",
//            body:  "This message was sent by me",
//        }
//    };
//  const response = await admin.messaging().sendToDevice(token, payload);
//  console.log(`response is ${response}`);





exports.onMessageCreate = functions.firestore
        .document('/chatRoom/{chatRoomId}/chats/{chatId}').onCreate(async (snapshot,context)=>{

    //Notification Details
    const type = snapshot.data().type;
    const text = snapshot.data().message;
    const chatRoomId = context.params.chatRoomId;
    const chatId = context.params.chatId;
    const isReply = snapshot.data().isReply=="True";
    const sendby = snapshot.data().userId;
    const toUser = chatRoomId.replace(sendby,"").replace("_","");
    const user = await admin.firestore().collection("users").doc(toUser).get();
    const owner = await admin.firestore().collection("users").doc(sendby).get();
    const payload = {
        data: {
            title: `${owner.data().username} ${isReply?'replied': 'sent'}  ${type=="text"?'a message': type=="image"?'an image':'a video'}`,
            imageUrl :owner.data().humanUrl,
            body:  type=="text" ? (text.length <= 100 ? text : text.substring(0, 97) + '...') : '',
            notificationType: "MESSAGE",
        }
    };
    const token =user.data().notificationToken;
    console.log( `token: ${token}`);
     const response = await admin.messaging().sendToDevice(token, payload);
});

exports.onLikeNotification = functions.https.onCall(async(req,res)=>{
    const userId = req.currentUserId;     //Liked by , userId
    const ownerId = req.ownerId;          //Owner of the post
    const postId = req.postId;            //Post id
    const username = req.currentUsername;
    const imageUrl = req.imageUrl;
    const user = await admin.firestore().collection("users").doc(ownerId).get();
    const token = user.data().notificationToken;
    const payload = {
        data:{
            title: `${username} liked your post`,
            imageUrl: imageUrl,
            postId : postId,
            notificationType : 'Liked',
        }
    };
    await admin.messaging().sendToDevice(token,payload);
    return {"notification": 'done!'};
});

exports.onAddPawNotification = functions.https.onCall(async(req,res)=>{
    const userId = req.currentUserId;     //Liked by , userId
    const otherUserId = req.otherUserId;          //Owner of the post
    const username = req.currentUsername;
    const imageUrl = req.imageUrl;
    const user = await admin.firestore().collection("users").doc(otherUserId).get();
    const token = user.data().notificationToken;
    const payload = {
        data:{
            title: `${username} sent a paw request`,
            imageUrl: imageUrl,
            notificationType : 'NEW_MAP_REQUEST',
        }
    };
    await admin.messaging().sendToDevice(token,payload);
    return {"notification": 'done!'};
});

exports.onPawRequestAcceptNotification = functions.https.onCall(async(req,res)=>{
    const userId = req.acceptedById;     //Liked by , userId
    const otherUserId = req.otherUserId;          //Owner of the post
    const username = req.acceptedByUsername;
    const imageUrl = req.imageUrl;
    const user = await admin.firestore().collection("users").doc(otherUserId).get();
    const token = user.data().notificationToken;
    const payload = {
        data:{
            title: `${username} accepted your paw request`,
            imageUrl: imageUrl,
            notificationType : 'MAP_REQUEST_ACCEPT',
        }
    };
    await admin.messaging().sendToDevice(token,payload);
    return {"notification": 'done!'};
});





exports.onCreateActivityPostItem = functions.firestore
.document('/posts/{userId}/userPosts/{activityPostItem}')
.onCreate(async (snapshot, context)=>
{
    const userId = context.params.userId;
    const userRef = admin.firestore().doc(`users/${userId}`);
    const doc = await userRef.get();


    const notificationToken = doc.data().notificationToken;
    const createActivityPostItem = snapshot.data();


    if(notificationToken)
    {
        sendNotification(notificationToken, createActivityPostItem);
    }
    else
    {
        console.log("No token for user , can not send Notification.")
    }


    function sendNotification(notificationToken, activityPostItem)
    {
        let body;

        switch (activityPostItem.type)
        {
            case "comment":
                body = `${activityPostItem.username} replied: ${activityPostItem.commentData}`;
                break;
            default:
            break;
        }

        const message =
        {
            notification : { body },
            token: notificationToken,
            data : { recipient : userId},
        };

        admin.messaging().send(message)
        .then(response =>
        {
            console.log("Successfully sent message", response);
        })
        .catch(error =>
        {
            console.log("Error sending message", error);
        })

    }
});




exports.onCreateFollower = functions.firestore
  .document("/followers/{userId}/userFollowers/{followerId}")
  .onCreate(async (snapshot, context)=>{

    console.log("Follower Created", snapshot.id);

    const userId = context.params.userId;

    const followerId = context.params.followerId;

    var accountInfo = admin
        .firestore()
        .collection("users")
        .doc(userId)
        .snapshot.data().isOpen

     var isOpen;

     if(accountInfo){
        isOpen = "open";
     }
     else{
        isOpen = "close";
     }


    const followedUserLocationRef = admin
        .firestore()
        .collection("location")
        .doc(isOpen)
        .collection("usersLocation")
        .doc(userId);


     const viewLocationRef = admin
        .firestore()
        .collection("viewLocation")
        .doc(followerId)
        .collection("othersLocation");

      const locationSnapshot = await followedUserLocationRef.get();

      if(locationSnapshot.exists){
        const locationId = locationSnapshot.id;
        const locationData = locationSnapshot.data();
        viewLocationRef.doc(locationId).set(locationData);
      }

  });


  exports.onDeleteFollower = functions.firestore
  .document('/followers/{userId}/userFollowers/{followerId}')
  .onDelete(async (snapshot, context)=> {
    console.log("Followers Deleted", snapshot.id);
    const userId = context.params.userId;

    const followerId = context.params.followerId;

    const viewLocationRef = admin
        .firestore()
        .collection("viewLocation")
        .doc(followerId)
        .collection("othersLocation")
        .where("ownerId", "==", userId);

     const locationSnapshot = await viewLocationRef.get();

     if(locationSnapshot.exists){
        locationSnapshot.ref.delete();
     }
  });

  exports.onUpdateLocation = functions.firestore
    .document("/location/{accountType}/usersLocation/{userId}")
    .onUpdate(async (change, context) => {

        const locationUpdated = change.after.data();
        const userId = context.params.userId;
        const accountType = context.params.accountType;

        const userFollowersRef = admin
            .firestore()
            .collection("followers")
            .doc(userId)
            .collection(userFollowers);

         const querySnapshot = await userFollowersRef.get();

         querySnapshot.forEach(doc => {
            const followerId = doc.id;

            admin
                .firestore()
                .collection("viewLocation")
                .doc(followerId)
                .collection("othersLocation")
                .doc(userId)
                .get()
                .then(doc => {
                    if(doc.exists){
                    doc.ref.update(locationUpdated);
                    }
                });
         });
    });



exports.onCreatePost = functions.firestore
    .document("/posts/{userId}/userPosts/{postId}")
    .onCreate(async (snapshot, context)=> {
        const postCreated = snapshot.data();
        const userId = context.params.ownerId;
        const postId = context.params.postId;

        admin.firestore()
            .collection("timeline")
            .doc("today")
            .collection("posts")
            .doc(postId)
            .set(postCreated,{merge: true});
    });

exports.onUpdatePost = functions.firestore
    .document("posts/{userId}/usersPosts/{postId}")
    .onUpdate(async (change, context)=>{
        const postUpdated = change.after.data();
        const userId = context.params.ownerId;
        const postId = context.params.postId;

        const time = admin.firestore.FieldValue.serverTimestamp();
        const postTime = context.params.timestamp;

        if(time == postTime){
            admin.firestore()
                .collection("timeline")
                .doc("today")
                .collection("posts")
                .doc(postId)
                .get()
                .then(doc => {
                    if(doc.exists){
                        doc.ref.set(postUpdated,{merge: true});
                    }
                });
        }
        else{
            admin.firestore()
                .collection("timeline")
                .doc("others")
                .collection("posts")
                .doc(postId)
                .get()
                .then(doc => {
                    if(doc.exists){
                        doc.ref.update(postUpdated,{merge: true});
                    }
                });
        }

    });


exports.onDeletePost = functions.firestore
    .document("posts/{userId}/usersPosts/{postId}")
    .onUpdate(async (change, context)=>{
        const userId = context.params.ownerId;
        const postId = context.params.postId;

        const time = admin.firestore.FieldValue.serverTimestamp();
        const postTime = context.params.timestamp;

        if(time == postTime){
            admin.firestore()
                .collection("timeline")
                .doc("today")
                .collection("posts")
                .doc(postId)
                .get()
                .then(doc => {
                    if(doc.exists){
                        doc.ref.delete();
                    }
                });
        }
        else{
            admin.firestore()
                .collection("timeline")
                .doc("others")
                .collection("posts")
                .doc(postId)
                .get()
                .then(doc => {
                    if(doc.exists){
                        doc.ref.delete();
                    }
                });
        }
    });


exports.generateMostLiked = functions.pubsub.schedule('0 0 * * *')
                                            .timeZone('Asia/Kolkata').onRun(async (context)=>{

 let m1 = moment();
    let m2 = moment();
    m1.add(-1,'days');
    m2.add(-1, 'days');
    m1.startOf('day');
    m2.endOf('day');
    let i = 0;
    console.log("DaY START IS ",m1.toDate()," Day end is",m2.toDate());
    var mostLikedId;
    var docData;
    const postRef =  admin.firestore().collection("timeline")
                              .doc("today")
                              .collection("posts");
    const snapshot = await postRef.orderBy("timestamp").where("timestamp",">",m1.toDate())
                                             .where("timestamp","<=",m2.toDate()).get();
   if(snapshot.empty){
        console.log("No matching documents.");
        return;
   }
    console.log("Printing IDs");
   snapshot.forEach(doc =>{
        if(doc.data().totalLikes > i){
            i = doc.data().totalLikes;
            mostLikedId = doc.id;
            docData = doc.data();
            console.log("most Liked id is ",mostLikedId," and totalLikes are ",i);

        }
   });
    admin.firestore()
         .collection("timeline")
         .doc("mostLiked")
         .collection("posts")
         .doc("first")
         .set(docData);

      console.log(`completd`);
});




exports.backgroundVideoUpload = functions.https.onCall(async(req, res)=>{

    const userId = req.userId;
    const videoId = req.videoId;
    const token = req.token;
    const videoRawPath = req.videoRawPath;

    const bucket = admin.storage().bucket();
    const videoFile = bucket.file('video/'+videoId+'.mp4');

    const resumableUpload = await videoFile.createResumableUpload();
    const url = resumableUpload[0];

    const payload = {
        data:{
             notificationType : 'videoUpload',
             url:url,
             toShow: 'false',
             videoId: videoId,
             videoRawPath: videoRawPath,
        }
    };
//    await admin.messaging().sendToDevice(token,payload);
    return url;
});
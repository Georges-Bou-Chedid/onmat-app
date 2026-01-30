const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendPushNotification = onDocumentCreated({
    document: "notifications/{notificationId}",
    region: "europe-west3"
}, async (event) => {
    const snapshot = event.data;
    if (!snapshot) return; // Safety check

    const data = snapshot.data();
    const receiverId = data.receiver_id;

    if (!receiverId) {
        console.log("No receiver_id in notification document");
        return;
    }

    // Search for token in instructors OR students
    let userDoc = await admin.firestore().collection("instructors").doc(receiverId).get();
    if (!userDoc.exists) {
        userDoc = await admin.firestore().collection("students").doc(receiverId).get();
    }

    const fcmToken = userDoc.data()?.fcmToken;

    if (!fcmToken) {
        console.log("No token found for user:", receiverId);
        return;
    }

    const message = {
        token: fcmToken,
        notification: {
            title: data.title || "OnMat Update",
            body: data.message || "",
        },
        data: {
            // FCM data keys/values must be strings
            type: String(data.type || "general"),
            click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
    };

    try {
        const response = await admin.messaging().send(message);
        console.log("Push sent successfully to:", receiverId, "ID:", response);
    } catch (error) {
        console.error("Error sending push:", error);
    }
});
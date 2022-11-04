package io.flutter.plugins;

import android.app.ActivityManager;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.os.Build;

import androidx.core.app.NotificationCompat;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;
import com.tml.miumiu.MainActivity;
import com.tml.miumiu.R;

import java.util.List;
import java.util.Map;

import me.leolin.shortcutbadger.ShortcutBadger;

public class AppFireBaseService  extends FirebaseMessagingService {

    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {
        android.util.Log.e("AndroidRuntime","msg "+remoteMessage);
        Map<String, String> data = remoteMessage.getData();
        if (data != null && !applicationInForeground()) {
            sendNotification(data);
        }
    }

    private boolean applicationInForeground() {
        ActivityManager activityManager = (ActivityManager) getSystemService(Context.ACTIVITY_SERVICE);
        List<ActivityManager.RunningAppProcessInfo> services = activityManager.getRunningAppProcesses();
        boolean isActivityFound = false;

        if (services.get(0).processName
                .equalsIgnoreCase(getPackageName()) && services.get(0).importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND) {
            isActivityFound = true;
        }

        return isActivityFound;
    }

    private void sendNotification(Map<String, String> data) {
        Intent intent       = new Intent(this, MainActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        intent.putExtra("fromnotification","1");
        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0 /* Request code */, intent,
                PendingIntent.FLAG_ONE_SHOT);

        int messageCount            = 0;
        try
        {
            if(Integer.parseInt(data.get("badge")) > 0)
                messageCount        = Integer.parseInt(data.get("badge"));

        }catch(Exception e){}

        String channelId            = getString(R.string.default_channel_id);
        Notification notification   = new NotificationCompat.Builder(this, channelId)
                .setContentTitle(getString(R.string.app_name))
                .setContentText(data.get("body"))
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentIntent(pendingIntent)
                .setAutoCancel(true)
                .setNumber(messageCount)
                .build();

        NotificationManager notificationManager =  (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(channelId,
                    "Channel human readable title",
                    NotificationManager.IMPORTANCE_DEFAULT);
            channel.setShowBadge(true);
            notificationManager.createNotificationChannel(channel);
        }

        int nid = 0;
        try{ nid    = Integer.parseInt(data.get("send_by")); } catch (Exception e){}
        ShortcutBadger.applyNotification(getApplicationContext(), notification, messageCount);
        notificationManager.notify(nid, notification);
    }

    private void sendNotification2() {
        Intent intent       = new Intent(this, MainActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        intent.putExtra("fromnotification","1");
        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0 /* Request code */, intent,
                PendingIntent.FLAG_ONE_SHOT);

        int messageCount            = 0;
        try
        {
            if(Integer.parseInt("12") > 0)
                messageCount        = Integer.parseInt("12");

        }catch(Exception e){}

        String channelId            = getString(R.string.default_channel_id);
        Notification notification   = new NotificationCompat.Builder(this, channelId)
                .setContentTitle(getString(R.string.app_name))
                .setContentText("testing")
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentIntent(pendingIntent)
                .setAutoCancel(true)
                .setNumber(messageCount)
                .build();

        NotificationManager notificationManager =  (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(channelId,
                    "Tellmelive Notifications",
                    NotificationManager.IMPORTANCE_DEFAULT);
            channel.setShowBadge(true);
            notificationManager.createNotificationChannel(channel);
        }

        int nid = 0;
        try{ nid    = Integer.parseInt("100"); } catch (Exception e){}
        ShortcutBadger.applyNotification(getApplicationContext(), notification, messageCount);
        notificationManager.notify(nid, notification);
    }

}

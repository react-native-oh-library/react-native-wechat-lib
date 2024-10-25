import React, { useState } from 'react';
import {
  Button,
  Alert,
  View,
  StyleSheet,
  ScrollView,
  Text,
  Image,
} from 'react-native';
import * as WeChat from '@react-native-ohos/react-native-wechat-lib';
import { APP_ID, APP_SECRET } from './src/constants';
import { launchImageLibrary } from 'react-native-image-picker';

const App = () => {
  const [qrcode, setQrcode] = useState('');

  const handleRegisterApp = async () => {
    const res = await WeChat.registerApp(APP_ID, '');
    console.log(
      '%c  WechatLibTurboModuleLogger registerApp res:',
      'color: #0e93e0;background: #aaefe5;',
      res,
    );
    Alert.alert(JSON.stringify(res));
  };

  const handleIsWXAppInstalled = async () => {
    WeChat.isWXAppInstalled().catch(err => {
      Alert.alert(JSON.stringify(err.message));
    });
  };

  const handleOpenWXApp = async () => {
    try {
      const res = await WeChat.openWXApp();
      console.log(
        '%c WechatLibTurboModuleLogger openWXApp res:',
        'color: #0e93e0;background: #aaefe5;',
        res,
      );
    } catch (error) {
      console.log('%c  error:', 'color: #0e93e0;background: #aaefe5;', error);
    }
  };

  const handleSendAuthRequest = async () => {
    try {
      const res = await WeChat.sendAuthRequest('snsapi_userinfo', 'none');
      console.log(
        '%c WechatLibTurboModuleLogger sendAuthRequest res:',
        'color: #0e93e0;background: #aaefe5;',
        res,
      );
    } catch (error) {
      console.log('%c  error:', 'color: #0e93e0;background: #aaefe5;', error);
    }
  };

  const handleAuthByScanRequest = async () => {
    try {
      const ret = await WeChat.authByScan(APP_ID, APP_SECRET, qrcode => {
        console.log(
          '%c WechatLibTurboModuleLogger authByScan qrcode:',
          'color: #0e93e0;background: #aaefe5;',
          qrcode,
        );
        // 拿到 qrcode 用 Image 去渲染
        setQrcode(qrcode);
      });
      console.log(
        '%c WechatLibTurboModuleLogger ret:',
        'color: #0e93e0;background: #aaefe5;',
        ret,
      );
    } catch (error) {
      console.log('%c  error:', 'color: #0e93e0;background: #aaefe5;', error);
    }
  };

  const handlePay = async () => {
    try {
      const res = await WeChat.pay({
        partnerId: '2480306091',
        prepayId: 'wx26161523845794ecced251acf2b6860000',
        nonceStr: 'vmall_240926161523_993_2774',
        timeStamp: '1727338524',
        package: 'Sign=WXPay',
        sign: 'rAqsrx5yLfRNBGvlHYuLhUsNK0OPeOLQ5xlvhxFo9guPU4HeNtzRdPaGAXAzXvn7V5chVe8sj3BfvDgwXlCKctCcFIllOgheyZbZ7btFC',
      });
      console.log(
        '%c WechatLibTurboModuleLogger pay res:',
        'color: #0e93e0;background: #aaefe5;',
        res,
      );
    } catch (error) {
      console.log('%c  error:', 'color: #0e93e0;background: #aaefe5;', error);
    }
  };

  const handleShareText = async () => {
    try {
      const res = await WeChat.shareText({
        text: '测试一下分享功能',
        scene: 0,
      });
      console.log('%c WechatLibTurboModuleLogger res:', 'color: #0e93e0;background: #aaefe5;', res);
    } catch (error) {
      console.log('%c  error:', 'color: #0e93e0;background: #aaefe5;', error);
    }
  };

  const handleShareRemoteImage = async () => {
    try {
      const res = await WeChat.shareImage({
        imageUrl: 'https://img.tukuppt.com/photo-big/00/10/77/619619681755c5463.jpg',
        scene: 0,
      });
      console.log('%c WechatLibTurboModuleLogger handleShareRemoteImage res:', 'color: #0e93e0;background: #aaefe5;', res);
    } catch (error) {
      console.log('%c  error:', 'color: #0e93e0;background: #aaefe5;', error);
    }
  };

  const handleShareLocalImage = async () => {
    try {
      // const res = await WeChat.shareImage({
      //   text: '测试一下分享功能',
      //   scene: 0,
      // });
      // console.log('%c WechatLibTurboModuleLogger res:', 'color: #0e93e0;background: #aaefe5;', res);
    } catch (error) {
      console.log('%c  error:', 'color: #0e93e0;background: #aaefe5;', error);
    }
  };

  return (
    <ScrollView style={styles.container}>
      <View style={{ height: 200 }}>
        <Button onPress={handleRegisterApp} title="registerApp" />
        <Button onPress={handleOpenWXApp} title="openWXApp" />
        <Button onPress={handleIsWXAppInstalled} title="isWXAppInstalled" />
        <Button onPress={handleSendAuthRequest} title="授权登录" />
        <Button onPress={handleAuthByScanRequest} title="扫码登录" />
        {qrcode && (
          <Image style={{ width: 100, height: 100 }} source={{ uri: qrcode }} />
        )}
        <Button onPress={handleShareText} title="shareText" />
        <Button onPress={handleShareRemoteImage} title="shareRemoteImage" />
        <Button onPress={handleShareLocalImage} title="shareLocalImage" />
        <Button onPress={handlePay} title="pay" />
        <View style={{ flex: 1, marginTop: 100 }}>
      <View style={{
        width: 160,
        height: 36,
        backgroundColor: 'hsl(190,50%,70%)',
        paddingHorizontal: 16,
        paddingVertical: 8,
        borderRadius: 8
      }} onTouchEnd={() => {
        launchImageLibrary({ mediaType: 'photo', selectionLimit: 1 }, async (data) => {
          if (data.assets?.length) {
            console.log('%c WechatLibTurboModuleLogger data.assets:', 'color: #0e93e0;background: #aaefe5;', data.assets);
            try {
              const res = await WeChat.shareLocalImage({
                imageUrl: data.assets[0].uri || '',
                scene: 0,
              });
              console.log('%c WechatLibTurboModuleLogger handleShareRemoteImage res:', 'color: #0e93e0;background: #aaefe5;', res);
            } catch (error) {
              console.log('%c  error:', 'color: #0e93e0;background: #aaefe5;', error);
            }
          }
        })
      }}>
        <Text style={{ width: '100%', height: '100%', fontWeight: 'bold', textAlign: 'center' }}>分享本地图片</Text>
      </View>
    </View>
      </View>
    </ScrollView>
  );
};

export default App;

const styles = StyleSheet.create({
  container: {
    width: '100%',
    flex: 1,
    paddingTop: 30,
    backgroundColor: '#f0f0f0',
  },
});

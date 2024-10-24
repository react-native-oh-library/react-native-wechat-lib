import React from 'react';
import { Button, Alert, View, StyleSheet, ScrollView } from 'react-native';
import * as WeChat from 'react-native-wechat-lib';
import { APP_ID } from './src/constants';

const App = () => {
  const handleRegisterApp = async () => {
    const res = await WeChat.registerApp(APP_ID, '');
    Alert.alert(JSON.stringify(res));
  };

  const handleIsWXAppInstalled = async () => {
    const res = await WeChat.isWXAppInstalled();
    Alert.alert(JSON.stringify(res));
  };

  const handleShareText = async () => {
    try {
      const res = await WeChat.shareText({
        text: '测试一下分享功能',
        scene: 2,
      });
      console.log('%c  res:', 'color: #0e93e0;background: #aaefe5;', res);
    } catch (error) {
      console.log('%c  error:', 'color: #0e93e0;background: #aaefe5;', error);
    }
  };

  const handleOpenWXApp = async () => {
    try {
      const res = await WeChat.openWXApp();
      console.log('%c  res:', 'color: #0e93e0;background: #aaefe5;', res);
    } catch (error) {
      console.log('%c  error:', 'color: #0e93e0;background: #aaefe5;', error);
    }
  };

  const handleSendAuthRequest = async () => {
    try {
      const res = await WeChat.sendAuthRequest("snsapi_userinfo", "none");
      console.log('%c  res:', 'color: #0e93e0;background: #aaefe5;', res);
    } catch (error) {
      console.log('%c  error:', 'color: #0e93e0;background: #aaefe5;', error);
    }
  };

  const handlePay = async () => {
    try {
      const res = await WeChat.pay({
        partnerId: "2480306091",
        prepayId: "wx26161523845794ecced251acf2b6860000",
        nonceStr: "vmall_240926161523_993_2774",
        timeStamp: "1727338524",
        package: "Sign=WXPay",
        sign: "rAqsrx5yLfRNBGvlHYuLhUsNK0OPeOLQ5xlvhxFo9guPU4HeNtzRdPaGAXAzXvn7V5chVe8sj3BfvDgwXlCKctCcFIllOgheyZbZ7btFC"
      });
      console.log('%c  res:', 'color: #0e93e0;background: #aaefe5;', res);
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
        <Button onPress={handleShareText} title="shareText" />
        <Button onPress={handleSendAuthRequest} title="授权登录" />
        <Button onPress={handlePay} title="pay" />
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

import React from 'react';
import { Button, Alert, View, StyleSheet, ScrollView } from 'react-native';
import WeChat from '@react-native-ohos/react-native-wechat-lib';

const App = () => {
  const handleRegisterApp = async () => {
    const res = await WeChat.registerApp('wxd5a474c635b8fd17', '');
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

  return (
    <ScrollView style={styles.container}>
      <View style={{ height: 200 }}>
        <Button onPress={handleRegisterApp} title="registerApp" />
        <Button onPress={handleOpenWXApp} title="openWXApp" />
        <Button onPress={handleIsWXAppInstalled} title="isWXAppInstalled" />
        <Button onPress={handleShareText} title="shareText" />
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

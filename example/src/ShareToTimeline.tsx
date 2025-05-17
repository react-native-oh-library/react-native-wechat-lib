import React, { useState } from 'react';
import {
  View,
  StyleSheet,
  Text,
  ScrollView,
  Button,
  Alert,
  Image,
} from 'react-native';
import { Tester, TestCase, TestSuite } from '@rnoh/testerino';
import * as WeChat from '@react-native-ohos/react-native-wechat-lib';
import { APP_ID, APP_SECRET } from './constants';
import { launchImageLibrary } from 'react-native-image-picker';

export const ShareToTimeline = () => {
  const [authRes, setAuthRes] = useState('');

  const handleRegisterApp = async () => {
    const res = await WeChat.registerApp(APP_ID, '');
    Alert.alert(JSON.stringify(res));
  };

  const handleShareTextToTimeline = async () => {
    try {
      await WeChat.shareToTimeline({
        type: "text",
        description: '测试分享文本到朋友圈',
      });
    } catch (error) {
      console.log('%c  error:', 'color: #0e93e0;background: #aaefe5;', error);
    }
  };

  const handleShareRemoteImageToTimeline = async () => {
    try {
      const res = await WeChat.shareToTimeline({
        type: "imageUrl",
        description: '测试分享远程图片到朋友圈',
        imageUrl: 'https://img.tukuppt.com/photo-big/00/10/77/619619681755c5463.jpg',
      });
      console.log(
        '%c WechatLibTurboModuleLogger handleShareRemoteImageToTimeline res:',
        'color: #0e93e0;background: #aaefe5;',
        res,
      );
    } catch (error) {
      console.log('%c  error:', 'color: #0e93e0;background: #aaefe5;', error);
    }
  };
  
  const handleShareLocalImageToTimeline = async () => {
    launchImageLibrary(
      { mediaType: 'photo', selectionLimit: 1 },
      async data => {
        if (data.assets?.length) {
          try {
            await WeChat.shareToTimeline({
              type: "imageFile",
              description: '测试分享本地图片到朋友圈',
              imageUrl: data.assets[0].uri || '',
            });
          } catch (error) {
            console.log('error:', error);
          }
        }
      },
    );
  };

  const handleShareResourcesImageToTimeline = async () => {
    try {
      const res = await WeChat.shareToTimeline({
        type: "imageUrl",
        description: '测试分享Resource目录下的图片到朋友圈',
        imageUrl: 'dog.jpg',
      });
      console.log(
        '%c WechatLibTurboModuleLogger handleShareResourcesImageToTimeline res:',
        'color: #0e93e0;background: #aaefe5;',
        res,
      );
    } catch (error) {
      console.log('%c  error:', 'color: #0e93e0;background: #aaefe5;', error);
    }
  };


  return (
    <Tester style={{ flex: 1 }}>
      <ScrollView>
        <TestSuite name="注册应用">
          <TestCase itShould="Click the button to register the app, and true will pop up when successful.">
            <Button title="registerApp" onPress={handleRegisterApp} />
          </TestCase>
        </TestSuite>
        <TestSuite name="分享文本到朋友圈">
          <TestCase
            itShould="
Click the button to pull up the WeChat moments and share text">
            <Button title="shareTextToTimeline" onPress={handleShareTextToTimeline} />
          </TestCase>
        </TestSuite>
        <TestSuite name="分享远程图片到朋友圈">
          <TestCase
            itShould="
Click the button to pull up the WeChat moments and share the remote image">
            <Button title="shareRemoteImageToTimeline" onPress={handleShareRemoteImageToTimeline} />
          </TestCase>
        </TestSuite>
        <TestSuite name="分享本地图片到朋友圈">
          <TestCase
            itShould="
Click the button to select a local picture, then pull up the WeChat moments and share the local picture">
            <Button title="shareLocalImageToTimeline" onPress={handleShareLocalImageToTimeline} />
          </TestCase>
        </TestSuite>
        <TestSuite name="分享资源目录图片到朋友圈">
          <TestCase
            itShould="
Click the button to pull up the WeChat moments and share a resource image">
            <Button title="shareResourcesImageToTimeline" onPress={handleShareResourcesImageToTimeline} />
          </TestCase>
        </TestSuite>
        <View style={{ height: 150 }} />
      </ScrollView>
    </Tester>
  );
};

const styles = StyleSheet.create({
  buttonContainer: {
    width: 80,
    height: 80,
  },
  buttonsContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 20,
  },
  text: {
    height: 20,
    width: 200,
    fontSize: 14,
  },
});

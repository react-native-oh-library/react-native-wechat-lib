import React from 'react';
import {
  Button,
  Alert,
  View,
  StyleSheet,
  ScrollView,
} from 'react-native';
import {registerApp, isWXAppInstalled, shareText} from "@react-native-ohos/react-native-wechat-lib"

const App = () => {
  const handleRegisterApp = async () => {
    const res = await registerApp();
    Alert.alert(JSON.stringify(res))
  };
  const handleIsWXAppInstalled = async () => {
    const res = await isWXAppInstalled();
    Alert.alert(JSON.stringify(res))
  };
  const handleShareText = async () => {
    const res = await shareText();
    Alert.alert(JSON.stringify(res))
  };

  return (
    <ScrollView style={styles.container}>
      <View style={{ height: 200 }}>
        <Button onPress={handleRegisterApp} title="registerApp" />
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

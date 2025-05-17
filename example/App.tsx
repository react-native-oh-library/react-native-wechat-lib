import React from 'react';

import { Tester } from '@rnoh/testerino';
import { NavigationContainer, Page } from './src/components/Navigation';
import { ShareToSession } from './src/ShareToSession';
import { ShareToTimeline } from './src/ShareToTimeline';

const App = () => {
  return (
    <NavigationContainer>
      <Page name="分享到会话">
        <Tester style={{ flex: 1 }}>
          <ShareToSession/>
        </Tester>
      </Page>
      <Page name="分享到朋友圈">
        <Tester style={{ flex: 1 }}>
          <ShareToTimeline/>
        </Tester>
      </Page>
    </NavigationContainer>
  );
};

export default App;

Discord で動作する Gemini の Bot。

## プライバシーについて

- この bot は [MESSAGE_CONTENT Intent](https://discord.com/developers/docs/events/gateway#message-content-intent) を要求します。これにより、この Bot は導入されたサーバーに投稿されたメッセージの内容を読み取り可能になります。
  - Bot 宛てのメンションおよびそれに対する返信のみ処理し、それ以外の投稿は読み取られません。
- この Bot 宛のメンションの内容は、[Google Gemini API](https://ai.google.dev/gemini-api/docs?hl=ja) に送信されます。

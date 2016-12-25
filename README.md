

# SimpleBOT

SimpleBOT merupakan salah satu contoh penggunaan SimpleAI yang dipergunakan untuk membuat BOT.
Memiliki fitur menjawab otomatis, dan belajar suatu definisi kata sederhana.
Kecerdasan Bot ini tergantung dari data entity dan intent yang Anda miliki, serta logic handler yang Anda buat.

Contoh penggunaan bot sederhana dengan SimpleBOT ini bisa anda coba dari situs [ai.fastplaz.com](http://ai.fastplaz.com) atau bisa melalu aplikasi chat **Telegram**, silahkan hubungi contact *'Fastplaz Bot'*.

Aplikasi SimpleBOT ini sudah kompatibel dengan Telegram API, sehingga anda bisa menggunakannya sebagai Telegram Bot.


**Dependency**

- FastPlaz_runtime
- SimpleBOT package

### Instalasi

Gunakan Lazarus, buka file "simplebot.lpi" dan *compile* file tersebut.

Akan terbentuk file binary di 'public_html/ai/simplebot.bin'

**SimpleBOT USAGE**

```
  SimpleBOT := TSimpleBotModule.Create;
  SimpleBOT.OnError := @OnErrorHandler;  // Your Custom Message
  text_response := SimpleBOT.Exec(Text);
  SimpleBOT.Free;

```

Fungsi 'OnErrorHandler' bisa digunakan untuk melakukan trapping terhadap kata/kalimat yang belum diakomodir oleh data SimpleAI

```delphi
function TMainModule.OnErrorHandler(const Message: string): string;
begin
  .
  .
  .
  // save to log file
  LogUtil.Add(Message, 'AI');
  
  // or save to database
  .
  .
  Result := 'Your custom messages';
end;
```

**Input**

method: POST

data disematkan di dalam body post, dengan format berikut

```
{"message":{"message_id":0,"text":"Your Message","chat":{"id":0}}}
```

format ini mengikuti pola message dari Telegram.


**Pengujian**

Pengujian dari command-line bisa dilakukan dengan syntax demikian:

```
curl "http://local-bot.fastplaz.com/ai/" -X POST -d '{"message":{"message_id":0,"chat":{"id":0},"text":"Hi"}}'
```

atau bisa dengan menggunakan aplikasi RESTClient lainnya.


![Format](img/format_01.png "Format")

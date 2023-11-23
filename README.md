# waas_sdk_flutter

The WaaS SDK is a client-side Flutter package that is required for key management operations. It exposes a subset of the WaaS APIs to the mobile developer.

## Getting Started

### Configuration for Android

Go to build.gradle in app-level of your project and update `minSdkVersion` and `targetSdkVersion`.  

```groovy
defaultConfig {
	minSdkVersion 30
	targetSdkVersion 31
}
```

### Configuration for iOS
Add the below scripts into your `Podfile`.

```ruby
post_install do |installer|
	installer.pods_project.targets.each do |target|
		target.build_configurations.each do |config|
			config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] =  'arm64'
			config.build_settings['ONLY_ACTIVE_ARCH'] =  'YES'
		end
	end
end
```

After run the **pod install**, open your iOS project on Xcode and link the `WaasSdkGo.xcframework` and `openssl_libcrypto.xcframework` to the **waas_sdk_flutter** target of Pods project.
![link frameworks](https://firebasestorage.googleapis.com/v0/b/coinable-335800.appspot.com/o/common%2Fimage.png?alt=media&token=10d4c6ea-1203-4309-bda7-29923a0da475)

## Usage

```dart
class  _MyAppState  extends  State<MyApp> {
	String  _platformVersion  =  'Unknown';
	final  _waasSdkFlutterPlugin  =  WaasSdkFlutter();

	@override
	void  initState() {
		super.initState();
		initPlatformState();
	} 

	// Platform messages are asynchronous, so we initialize in an async method.
	Future<void> initPlatformState() async {
		String  platformVersion;
		// Platform messages may fail, so we use a try/catch PlatformException.
		// We also handle the message potentially returning null.
		try {
			platformVersion  =  await _waasSdkFlutterPlugin.getPlatformVersion() ?? 'Unknown platform version';
		} on  PlatformException {
			platformVersion  =  'Failed to get platform version.';
		}

		// If the widget was removed from the tree while the asynchronous platform
		// message was in flight, we want to discard the reply rather than calling
		// setState to update our non-existent appearance.
		if (!mounted) return;
		
		setState(() {
			_platformVersion  =  platformVersion;
		});
	}

	void  initMPCSdk() {
		_waasSdkFlutterPlugin.initMPCSdk(true).then((value) {
			_waasSdkFlutterPlugin.bootstrapDevice('passcode123').then((value) {
				_waasSdkFlutterPlugin
					.getRegistrationData()
					.then((value) =>  print('====registration data: $value'))
					.catchError((e) =>  print('====registrationDevice error: $e'));
			}).catchError((e) =>  print('====bootstrapDevice error: $e'));
		}).catchError((e) =>  print('====mpcsdk initialize error: $e'));
	}
		
	@override
	Widget  build(BuildContext  context) {
		return  MaterialApp(
			home:  Scaffold(
				appBar:  AppBar(
					title:  const  Text('Plugin example app'),
				),
				body:  Center(
					child:  Text('Running on: $_platformVersion\n'),
				),
				floatingActionButton:  FloatingActionButton.extended(
					onPressed:  initMPCSdk,
					label:  const  Text('MPC Sdk Tutorial'),
				),
			),
		);
	}
}
```

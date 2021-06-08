#import "./FileIconFetcher.h"

#include <map>
#include <napi.h>

using namespace Napi;

ThreadSafeFunction tsfn;

Value GetFileIcon( const CallbackInfo& info ) {
  Napi::Env env = info.Env();

  if (info.Length() != 4) {
    Error::New(info.Env(), "Wrong number of arguments")
        .ThrowAsJavaScriptException();
  }

  std::string input_string = info[0].ToString().Utf8Value();
  std::string output_string = info[1].ToString().Utf8Value();
  int32_t size = info[2].As<Number>().Uint32Value();

  NSString *input = [NSString stringWithCString:input_string.c_str()
                                       encoding:NSUTF8StringEncoding];
  NSString *output = [NSString stringWithCString:output_string.c_str()
                                       encoding:NSUTF8StringEncoding];

  tsfn = ThreadSafeFunction::New(env, info[3].As<Function>(),
      "Thread Safe Function", 0, 1, [](Napi::Env) {});

  FileIconFetcher *fetcher = [[FileIconFetcher alloc] init];

  auto callback = [](Napi::Env env, Function jsCallback, std::map<std::string, std::string> *values) {
    jsCallback.Call({});
  };

  [fetcher getFileIconAtPath:input withOutput:output atSize:size withSuccess:^() {
    std::map<std::string, std::string> *values = new std::map<std::string, std::string>();

    napi_status status = tsfn.BlockingCall(values, callback);
    if (status != napi_ok) {
      NSLog(@"Error occured when running callback on the event loop.\n");
    }

    tsfn.Release();
  } withError:^(NSError * _Nonnull error) {
    std::map<std::string, std::string> *values = new std::map<std::string, std::string>();
    (*values)["is_error"] = "true";
    (*values)["code"] = std::string([[@(error.code) stringValue] UTF8String]);
    (*values)["message"] = std::string([error.description UTF8String]);

    napi_status status = tsfn.BlockingCall(values, callback);
    if (status != napi_ok) {
      NSLog(@"Error occured when running callback on the event loop.\n");
    }

    tsfn.Release();
  }];

  return Napi::Boolean::New(env, true);
}

Object Init(Env env, Object exports) {
  exports.Set(String::New(env, "getFileIcon"),
              Function::New(env, GetFileIcon));

  return exports;
}

NODE_API_MODULE(main, Init)

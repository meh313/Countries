{{flutter_js}}
{{flutter_build_config}}

// Serve CanvasKit from the app's own origin instead of the gstatic CDN so
// the app is fully self-contained (works offline and behind strict proxies).
_flutter.loader.load({
  config: {
    canvasKitBaseUrl: "canvaskit/",
  },
});

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future OOffStage(Widget widget,
    {Duration? wait, bool openFilePreview = true, bool saveToDevice = false, String fileName = 'davinci', String? albumName, double? pixelRatio, bool returnImageUint8List = false}) async {
  /// finding the widget in the current context by the key.
  // final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();

  /// create a new pipeline owner
  // final PipelineOwner pipelineOwner = PipelineOwner();

  /// create a new build owner
  // final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());

  // Size logicalSize = ui.window.physicalSize / ui.window.devicePixelRatio;
  pixelRatio ??= View.of(Get.context!).devicePixelRatio;
  // assert(openFilePreview != returnImageUint8List);

  /*try {
    final RenderView renderView = RenderView(
      child: RenderPositionedBox(alignment: Alignment.center, child: repaintBoundary),
      configuration: ViewConfiguration(
        size: logicalSize,
        devicePixelRatio: 1.0,
      ),
      view: ui.,
    );

    /// setting the rootNode to the renderview of the widget
    pipelineOwner.rootNode = renderView;

    /// setting the renderView to prepareInitialFrame
    renderView.prepareInitialFrame();

    /// setting the rootElement with the widget that has to be captured
    final RenderObjectToWidgetElement<RenderBox> rootElement = RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: widget,
      ),
    ).attachToRenderTree(buildOwner);

    ///adding the rootElement to the buildScope
    buildOwner.buildScope(rootElement);

    /// if the wait is null, sometimes
    /// the then waiting for the given [wait] amount of time and
    /// then creating an image via a [RepaintBoundary].

    if (wait != null) {
      await Future.delayed(wait);
    }

    ///adding the rootElement to the buildScope
    buildOwner.buildScope(rootElement);

    /// finialize the buildOwner
    buildOwner.finalizeTree();

    ///Flush Layout
    pipelineOwner.flushLayout();

    /// Flush Compositing Bits
    pipelineOwner.flushCompositingBits();

    /// Flush paint
    pipelineOwner.flushPaint();

    /// we start the createImageProcess once we have the repaintBoundry of
    /// the widget we attached to the widget tree.
    return await _createImageProcess(
      saveToDevice: saveToDevice,
      albumName: albumName,
      fileName: fileName,
      returnImageUint8List: returnImageUint8List,
      openFilePreview: openFilePreview,
      repaintBoundary: repaintBoundary,
      pixelRatio: pixelRatio,
      returnFile: true,
    );
  } catch (e) {
    print(e);
    return <Uint8List>[];
  }*/
}

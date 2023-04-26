import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:interactive_diary/features/home/bloc/load_diary_cubit.dart';
import 'package:interactive_diary/features/home/content_panel/contents_bottom_panel_view.dart';
import 'package:interactive_diary/features/home/content_panel/widgets/no_post_view.dart';
import 'package:interactive_diary/features/home/data/diary_display_content.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';

import '../../../widget_tester_extension.dart';
import 'contents_bottom_panel_view_test.mocks.dart';

@GenerateMocks([LoadDiaryCubit])
void main() {
  initializeDateFormatting();

  final MockLoadDiaryCubit loadDiaryCubit = MockLoadDiaryCubit();

  setUp(() {
    when(loadDiaryCubit.stream)
        .thenAnswer((realInvocation) => Stream.value(LoadDiaryInitial()));
    when(loadDiaryCubit.state)
        .thenAnswer((realInvocation) => LoadDiaryInitial());
  });

  tearDown(() {
    reset(loadDiaryCubit);
  });

  testWidgets(
      'when controller does not request to show panel, panel should be hidden',
      (WidgetTester widgetTester) async {
    final ContentsBottomPanelController controller =
        ContentsBottomPanelController();
    final ContentsBottomPanelView contentsBottomPanelView =
        ContentsBottomPanelView(
      controller: controller,
      location: const LatLng(0, 0),
    );

    await mockNetworkImagesFor(() =>
        widgetTester.blocWrapAndPump<LoadDiaryCubit>(
            loadDiaryCubit, contentsBottomPanelView));

    // before show, slide animation stays at Offset(0.0, 1.0)
    final SlideTransition slideTransition =
        widgetTester.widget(find.byType(SlideTransition));

    // panel is hidden at y = 100% height
    expect(slideTransition.position.value, const Offset(0.0, 1.0));

    // and list height is 0
    final SizedBox sizedBox = widgetTester.widget(find.ancestor(
        of: find.byType(BlocBuilder<LoadDiaryCubit, LoadDiaryState>),
        matching: find.descendant(
            of: find.byType(Column), matching: find.byType(SizedBox))));

    expect(sizedBox.height, 0);
  });

  testWidgets('when controller request to show panel, panel should be visible',
      (WidgetTester widgetTester) async {
    final ContentsBottomPanelController controller =
        ContentsBottomPanelController();
    final ContentsBottomPanelView contentsBottomPanelView =
        ContentsBottomPanelView(
      controller: controller,
      location: const LatLng(0, 0),
    );

    controller.show();
    await mockNetworkImagesFor(() =>
        widgetTester.blocWrapAndPump<LoadDiaryCubit>(
            loadDiaryCubit, contentsBottomPanelView));

    // before show, slide animation stays at Offset(0.0, 1.0)
    final SlideTransition slideTransition =
        widgetTester.widget(find.byType(SlideTransition));

    // panel is hidden at y = 100% height
    expect(slideTransition.position.value, const Offset(0.0, 1.0));

    // and list height is 0 because there's no drag yet
    final SizedBox sizedBox = widgetTester.widget(find.ancestor(
        of: find.byType(BlocBuilder<LoadDiaryCubit, LoadDiaryState>),
        matching: find.descendant(
            of: find.byType(Column), matching: find.byType(SizedBox))));

    expect(sizedBox.height, 0);
  });

  testWidgets(
      'when controller request to hide panel, then panel should be hidden',
      (WidgetTester widgetTester) async {
    final ContentsBottomPanelController controller =
        ContentsBottomPanelController();
    final ContentsBottomPanelView contentsBottomPanelView =
        ContentsBottomPanelView(
      controller: controller,
      location: const LatLng(0, 0),
    );

    controller.show();
    await mockNetworkImagesFor(() =>
        widgetTester.blocWrapAndPump<LoadDiaryCubit>(
            loadDiaryCubit, contentsBottomPanelView));

    // before show, slide animation stays at Offset(0.0, 1.0)
    final SlideTransition slideTransition =
        widgetTester.widget(find.byType(SlideTransition));

    // panel is hidden at y = 100% height
    expect(slideTransition.position.value, const Offset(0.0, 1.0));

    controller.dismiss();
    await widgetTester.pumpAndSettle();

    // panel is hidden at y = 100% height
    expect(slideTransition.position.value, const Offset(0.0, 1.0));
  });

  testWidgets('test drag', (WidgetTester widgetTester) async {
    final ContentsBottomPanelController controller =
        ContentsBottomPanelController();
    final ContentsBottomPanelView contentsBottomPanelView =
        ContentsBottomPanelView(
      controller: controller,
      location: const LatLng(0, 0),
    );

    controller.show();
    await mockNetworkImagesFor(() =>
        widgetTester.blocWrapAndPump<LoadDiaryCubit>(
            loadDiaryCubit, contentsBottomPanelView));

    // drag on Divider
    await widgetTester.drag(
        find.descendant(
            of: find.byType(GestureDetector),
            matching: find.ancestor(
                of: find.byType(Divider), matching: find.byType(Container))),
        const Offset(0.0, -200));
    await widgetTester.pumpAndSettle();

    // list height is 200 because it's dragged up
    final SizedBox sizedBox = widgetTester.widget(find.ancestor(
        of: find.byType(BlocBuilder<LoadDiaryCubit, LoadDiaryState>),
        matching: find.descendant(
            of: find.byType(Column), matching: find.byType(SizedBox))));
    expect(sizedBox.height, 200);
  });

  testWidgets(
      'given the diary list is empty, when show content bottom panel, then show NoPostView',
      (widgetTester) async {
    final ContentsBottomPanelController controller =
        ContentsBottomPanelController();
    final ContentsBottomPanelView contentsBottomPanelView =
        ContentsBottomPanelView(
      controller: controller,
      location: const LatLng(0, 0),
    );

    await mockNetworkImagesFor(() =>
        widgetTester.blocWrapAndPump<LoadDiaryCubit>(
            loadDiaryCubit, contentsBottomPanelView));

    expect(find.byType(NoPostView), findsOneWidget);
  });

  testWidgets(
      'given diary list is not empty, when show content bottom panel, then do not show NoPostView',
      (widgetTester) async {
    final LoadDiaryState state = LoadDiaryCompleted([
      DiaryDisplayContent(
          userDisplayName: 'userDisplayName',
          dateTime: DateTime.now(),
          userPhotoUrl: 'userPhotoUrl',
          plainText: 'plainText')
    ]);
    when(loadDiaryCubit.state).thenAnswer((realInvocation) => state);
    when(loadDiaryCubit.stream)
        .thenAnswer((realInvocation) => Stream.value(state));

    final ContentsBottomPanelController controller =
        ContentsBottomPanelController();
    final ContentsBottomPanelView contentsBottomPanelView =
        ContentsBottomPanelView(
      controller: controller,
      location: const LatLng(0, 0),
    );

    await mockNetworkImagesFor(() =>
        widgetTester.blocWrapAndPump<LoadDiaryCubit>(
            loadDiaryCubit, contentsBottomPanelView));

    expect(find.byType(NoPostView), findsNothing);
  });
}

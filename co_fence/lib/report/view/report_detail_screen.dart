import 'package:co_fence/common/components/my_elevated_button.dart';
import 'package:co_fence/common/const/colors.dart';
import 'package:co_fence/common/const/data.dart';
import 'package:co_fence/common/layout/default_layout.dart';
import 'package:co_fence/report/model/action_status.dart';
import 'package:co_fence/report/model/report_status.dart';
import 'package:co_fence/report/provider/report_provider.dart';
import 'package:co_fence/report/service/report_services.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class ReportDetailScreen extends ConsumerStatefulWidget {
  const ReportDetailScreen({
    super.key,
  });

  @override
  ConsumerState<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends ConsumerState<ReportDetailScreen> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _detailController = TextEditingController();
  bool isLoading = false;
  int currentPage = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _titleController = TextEditingController(
      text: ref.watch(reportProvider).reportSubject,
    );
    _detailController = TextEditingController(
      text: ref.watch(reportProvider).reportDetail,
    );
    fetchReportDetail();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  fetchReportDetail() async {
    final resp = await ReportServices().fetchReportDetail(
        ref: ref,
        reportId:
            GoRouterState.of(context).uri.queryParameters['reportId'] ?? '');
    ref.read(reportProvider.notifier).updateReport(
          userName: resp.userName,
          createdAt: resp.createdAt,
          reportImageUrls: resp.reportImageUrls,
          reportDetail: resp.reportDetail,
          reportSubject: resp.reportSubject,
          reportStatus: resp.reportStatus,
          actionStatus: resp.actionStatus,
        );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      appBarTitle: 'Report Detail',
      actions: [
        IconButton(
          icon: const Icon(
            Icons.delete_outline,
            size: 30.0,
          ),
          onPressed: () {
            showCupertinoDialog(
              context: context,
              builder: (BuildContext context) {
                return CupertinoAlertDialog(
                  title: const Text('Delete Report'),
                  actions: [
                    CupertinoDialogAction(
                      child: const Text(
                        'No',
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                      onPressed: () {
                        context.pop(context);
                      },
                    ),
                    CupertinoDialogAction(
                      child: const Text(
                        'Yes',
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                      onPressed: () async {
                        context.pop(context);
                        // 삭제 api 호출

                        // 다시 리스트로 이동
                        context.go('/report_list');
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
      context: context,
      child: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ),
          child: CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    const Gap(10.0),
                    _renderLabel(ref),
                    _renderTextField(
                      controller: _titleController,
                      hintText: '기계 결함',
                      context: context,
                      ref: ref,
                    ),
                    const Gap(10.0),
                    _renderReportStatusDropdownMenu(
                      context: context,
                      ref: ref,
                    ),
                    const Gap(10.0),
                    _renderActionStatusDropdownMenu(
                      context: context,
                      ref: ref,
                    ),
                    const Gap(10.0),
                    _renderImageListPageBuilder(
                      context: context,
                      ref: ref,
                    ),
                    const Gap(10.0),
                    _renderReportDetail(
                      context: context,
                      ref: ref,
                    ),
                    const Gap(10.0),
                    _renderEditButton(
                      onPressed: () async {
                        await ref.read(reportProvider.notifier).createReport();
                        context.go('/report_list');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _renderLabel(
    WidgetRef ref,
  ) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: Column(
        children: [
          Row(
            children: [
              const Text('Reporter: '),
              Text('${ref.watch(reportProvider).userName}'),
            ],
          ),
          Row(
            children: [
              const Text('Reported Date: '),
              Text(
                ref.watch(reportProvider).createdAt.toString().substring(0, 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _renderTextField({
    required TextEditingController controller,
    required String hintText,
    required BuildContext context,
    required WidgetRef ref,
  }) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          10.0,
        ),
        color: Colors.white,
        border: Border.all(
          color: PRIMARY_COLOR,
          width: 2.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Gap(
            20.0,
          ),
          const Expanded(
            flex: 1,
            child: Text(
              'Title',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const VerticalDivider(
            color: PRIMARY_COLOR,
            thickness: 2.0,
          ),
          const Gap(
            10.0,
          ),
          Expanded(
            flex: 2,
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: ref.watch(reportProvider).reportSubject,
                border: InputBorder.none,
              ),
            ),
          ),
          const Gap(10.0),
        ],
      ),
    );
  }

  Widget _renderReportStatusDropdownMenu({
    required BuildContext context,
    required WidgetRef ref,
  }) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          10.0,
        ),
        color: Colors.white,
        border: Border.all(
          color: PRIMARY_COLOR,
          width: 2.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Gap(
            20.0,
          ),
          const Expanded(
            flex: 1,
            child: Text(
              'Category',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const VerticalDivider(
            color: PRIMARY_COLOR,
            thickness: 2.0,
          ),
          const Gap(
            10.0,
          ),
          Expanded(
            flex: 2,
            child: DropdownButtonFormField(
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              value: ref.watch(reportProvider).reportStatus,
              onChanged: (value) {
                ref.read(reportProvider.notifier).updateReport(
                      reportStatus: value as ReportStatus,
                    );
              },
              items: ReportStatus.values.map((ReportStatus reportStatus) {
                return DropdownMenuItem(
                  value: reportStatus,
                  child: Text(
                    reportStatus.code,
                  ),
                );
              }).toList(),
            ),
          ),
          const Gap(10.0),
        ],
      ),
    );
  }

  Widget _renderActionStatusDropdownMenu({
    required BuildContext context,
    required WidgetRef ref,
  }) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          10.0,
        ),
        color: Colors.white,
        border: Border.all(
          color: PRIMARY_COLOR,
          width: 2.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Gap(
            20.0,
          ),
          const Expanded(
            flex: 1,
            child: Text(
              'Status',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const VerticalDivider(
            color: PRIMARY_COLOR,
            thickness: 2.0,
          ),
          const Gap(
            10.0,
          ),
          Expanded(
            flex: 2,
            child: DropdownButtonFormField(
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              value: ref.watch(reportProvider).actionStatus,
              onChanged: (value) {
                ref.read(reportProvider.notifier).updateReport(
                      actionStatus: value as ActionStatus,
                    );
              },
              items: ActionStatus.values.map((ActionStatus actionStatus) {
                return DropdownMenuItem(
                  value: actionStatus,
                  child: Text(
                    actionStatus.code,
                  ),
                );
              }).toList(),
            ),
          ),
          const Gap(10.0),
        ],
      ),
    );
  }

  Widget _renderImageListPageBuilder({
    required BuildContext context,
    required WidgetRef ref,
  }) {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white,
        border: Border.all(
          color: PRIMARY_COLOR,
          width: 2.0,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: ref.watch(reportProvider).reportImageUrls!.length,
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Image.network(
                    firebasePrefix(isReport: true) +
                        ref.watch(reportProvider).reportImageUrls![index],
                    width: 300.0,
                    height: 100.0,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
          _renderPageIndicator(),
        ],
      ),
    );
  }

  Widget _renderReportDetail({
    required BuildContext context,
    required WidgetRef ref,
  }) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          10.0,
        ),
        color: Colors.white,
        border: Border.all(
          color: PRIMARY_COLOR,
          width: 2.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          '${ref.watch(reportProvider).reportDetail}',
          maxLines: 10,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }

  Widget _renderEditButton({
    required VoidCallback onPressed,
  }) {
    return MyElevatedButton(
      buttonText: 'Edit',
      onPressed: onPressed,
    );
  }

  Widget _renderPageIndicator() {
    int dotsCount = ref.watch(reportProvider).reportImageUrls!.length;
    return DotsIndicator(
      dotsCount: dotsCount,
      position: currentPage,
      decorator: const DotsDecorator(
        color: Colors.grey,
        activeColor: PRIMARY_COLOR,
      ),
    );
  }
}

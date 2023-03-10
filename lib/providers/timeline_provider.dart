import 'package:flutter/material.dart';
import 'package:mastodon/dao/account_dao.dart';
import 'package:mastodon/dao/attachment_dao.dart';
import 'package:mastodon/dao/status_dao.dart';
import 'package:mastodon/dao/timeline_dao.dart';
import 'package:mastodon/enties/entries.dart';
import 'package:mastodon/helpers/mastodon_helper.dart';
import 'package:mastodon/helpers/sort_statuses.dart';

class TimelineProvider extends ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;

  StatusDao statusDao;
  AccountDao accountDao;
  AttachmentDao attachmentDao;
  TimelineDao timelineDao;

  List<StatusEntity> _statuses = [];
  List<StatusEntity> get statuses => _statuses;
  final pageSize = 20;

  TimelineProvider({
    required this.statusDao,
    required this.accountDao,
    required this.attachmentDao,
    required this.timelineDao,
  });

  Future<void> refresh() async {
    _statuses = await statusDao.findAllStatuses();
    for (var s in _statuses) {
      await timelineDao.populateStatus(s);
    }
    sortStatusesByReply(_statuses, offset: const Duration(minutes: 10));
    notifyListeners();
  }

  loadTimeline() async {
    _loading = true;
    notifyListeners();

    try {
      final resp = await MastodonHelper.api?.v1.timelines
          .lookupHomeTimeline(limit: pageSize);
      if (resp != null) {
        await timelineDao.saveTimelineStatuses(resp.data);
        await refresh();
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  loadTimelineMore() async {
    if (_loading) return;

    _loading = true;
    notifyListeners();

    try {
      final status = await statusDao.getOldestStatus();
      final resp = await MastodonHelper.api?.v1.timelines
          .lookupHomeTimeline(maxStatusId: status?.id, limit: pageSize);
      if (resp != null) {
        await timelineDao.saveTimelineStatuses(resp.data);
        await refresh();
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  unfavoriteStatus(String statusId) async {
    try {
      final resp = await MastodonHelper.api?.v1.statuses
          .destroyFavourite(statusId: statusId);
      if (resp != null) {
        await timelineDao.saveTimelineStatuses([resp.data]);
        await refresh();
      }
    } finally {
      notifyListeners();
    }
  }

  favoriteStatus(String statusId) async {
    try {
      final resp = await MastodonHelper.api?.v1.statuses
          .createFavourite(statusId: statusId);
      if (resp != null) {
        await timelineDao.saveTimelineStatuses([resp.data]);
        await refresh();
      }
    } finally {
      notifyListeners();
    }
  }

  reblogStatus(String statusId) async {
    try {
      final resp = await MastodonHelper.api?.v1.statuses
          .createReblog(statusId: statusId);
      if (resp != null) {
        await timelineDao.saveTimelineStatuses([resp.data]);
        await refresh();
      }
    } finally {
      notifyListeners();
    }
  }
}

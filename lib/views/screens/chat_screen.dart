import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/group_mission.dart';
import '../mainapp/main_drawer.dart';
import '../../providers/user_provider.dart';

class ChatScreen extends StatefulWidget {
  final GroupMission mission;

  const ChatScreen({super.key, required this.mission});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ImagePicker _picker = ImagePicker();
  int _selectedTab = 0; // 0: 인증피드, 1: 공지, 2: 멤버
  bool _isUploading = false;

  late CollectionReference _feedRef;
  late CollectionReference _noticeRef;

  @override
  void initState() {
    super.initState();
    _feedRef = FirebaseFirestore.instance
        .collection('group_missions')
        .doc(widget.mission.id)
        .collection('feed');
    _noticeRef = FirebaseFirestore.instance
        .collection('group_missions')
        .doc(widget.mission.id)
        .collection('notices');
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
    if (photo != null) {
      if (mounted) {
        _showPostDialog(File(photo.path));
      }
    }
  }

  void _showNoticeDialog({DocumentSnapshot? doc}) {
    final TextEditingController noticeController = TextEditingController(
      text: doc != null ? doc['content'] : '',
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(doc == null ? '공지 등록하기' : '공지 수정하기',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: noticeController,
          style: const TextStyle(color: Colors.white),
          maxLines: 5,
          decoration: InputDecoration(
            hintText: '멤버들에게 전달할 공지사항을 입력하세요.',
            hintStyle: const TextStyle(color: Colors.white24),
            filled: true,
            fillColor: Colors.white10,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (noticeController.text.isNotEmpty) {
                final userProvider = context.read<UserProvider>();
                if (doc == null) {
                  await _noticeRef.add({
                    'content': noticeController.text,
                    'createdAt': FieldValue.serverTimestamp(),
                    'userName': userProvider.nickname,
                    'userId': userProvider.userId,
                  });
                } else {
                  await doc.reference.update({
                    'content': noticeController.text,
                    'updatedAt': FieldValue.serverTimestamp(),
                  });
                }
              }
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
            child: const Text('저장', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showPostDialog(File file) {
    final TextEditingController contentController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: !_isUploading,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E2C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('인증 피드 올리기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(file, height: 150, width: double.infinity, fit: BoxFit.cover),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: '오늘의 성취를 공유해보세요!',
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
          actions: [
            if (!_isUploading)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소', style: TextStyle(color: Colors.grey)),
              ),
            ElevatedButton(
              onPressed: _isUploading ? null : () async {
                if (contentController.text.isNotEmpty) {
                  setDialogState(() => _isUploading = true);
                  try {
                    final userProvider = context.read<UserProvider>();
                    String imageUrl = '';
                    
                    // 1. Firebase Storage 이미지 업로드
                    final storageRef = FirebaseStorage.instance
                        .ref()
                        .child('mission_feeds/${widget.mission.id}/${DateTime.now().millisecondsSinceEpoch}.jpg');
                    await storageRef.putFile(file);
                    imageUrl = await storageRef.getDownloadURL();

                    // 2. Firestore 데이터 저장
                    await _feedRef.add({
                      'userId': userProvider.userId,
                      'userName': userProvider.nickname,
                      'content': contentController.text,
                      'imageUrl': imageUrl,
                      'likes': [], // 좋아요 누른 유저 ID 리스트
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('인증 사진이 성공적으로 업로드되었습니다!')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('업로드 실패: $e')),
                      );
                    }
                  } finally {
                    setDialogState(() => _isUploading = false);
                    setState(() => _isUploading = false);
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              child: _isUploading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('업로드', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      endDrawer: const MainEndDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.mission.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back_ios, color: Colors.grey, size: 12),
                  SizedBox(width: 4),
                  Text('목록으로', style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            ),
          ),
          _buildMissionHeader(),
          const SizedBox(height: 20),
          _buildTabs(),
          Expanded(child: _buildTabContent()),
        ],
      ),
      floatingActionButton: _selectedTab == 0
          ? FloatingActionButton.extended(
              onPressed: _takePhoto,
              backgroundColor: Colors.blueAccent,
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              label: const Text('인증 업로드', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildFeedList();
      case 1:
        return _buildNoticeTab();
      case 2:
        return _buildMembersTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildNoticeTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: GestureDetector(
            onTap: () => _showNoticeDialog(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.5)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.orangeAccent, size: 18),
                  SizedBox(width: 8),
                  Text(
                    '새 공지 등록하기',
                    style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _noticeRef.orderBy('createdAt', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.campaign_outlined, color: Colors.white10, size: 60),
                      SizedBox(height: 16),
                      Text('아직 등록된 공지가 없습니다.', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: docs.length,
                itemBuilder: (context, index) => _buildNoticeCard(docs[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNoticeCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final myUserId = context.read<UserProvider>().userId;
    // 방장(리더)이거나 공지 작성자인 경우 삭제 권한 부여
    final bool canManage = widget.mission.leaderName == '나' || data['userId'] == myUserId;

    final date = data['createdAt'] != null 
        ? DateFormat('yyyy.MM.dd').format((data['createdAt'] as Timestamp).toDate())
        : '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.notifications_active, color: Colors.orangeAccent, size: 20),
                  const SizedBox(width: 8),
                  const Text('방장 공지', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(date, style: const TextStyle(color: Colors.white24, fontSize: 12)),
                ],
              ),
              if (canManage)
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _showNoticeDialog(doc: doc),
                      child: const Icon(Icons.edit, color: Colors.white38, size: 18),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => doc.reference.delete(),
                      child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(data['content'], style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildMembersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 1, // 임시
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2C),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blueAccent.withValues(alpha: 0.2),
                child: const Icon(Icons.person, color: Colors.blueAccent, size: 22),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text('나', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.5)),
                ),
                child: const Text('방장', style: TextStyle(color: Colors.orangeAccent, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMissionHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.run_circle, color: Colors.orangeAccent, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.mission.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('리더: ${widget.mission.leaderName} • ${widget.mission.currentParticipants}명 참여',
                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: widget.mission.progress,
              backgroundColor: Colors.white10,
              color: Colors.blueAccent,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('달성률 ${(widget.mission.progress * 100).toInt()}%', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(widget.mission.remainingTime, style: const TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 50,
      decoration: BoxDecoration(color: const Color(0xFF1E1E2C), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _tabItem(0, '인증피드'),
          _tabItem(1, '공지'),
          _tabItem(2, '멤버'),
        ],
      ),
    );
  }

  Widget _tabItem(int index, String title) {
    bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          margin: const EdgeInsets.all(4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.blueAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 14)),
        ),
      ),
    );
  }

  Widget _buildFeedList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _feedRef.orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_library_outlined, color: Colors.white10, size: 60),
                SizedBox(height: 16),
                Text('아직 인증된 피드가 없습니다.\n첫 번째 인증을 올려보세요!', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) => _buildFeedCard(docs[index]),
        );
      },
    );
  }

  Widget _buildFeedCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final myUserId = context.read<UserProvider>().userId;
    final List likes = data['likes'] ?? [];
    final bool isLiked = likes.contains(myUserId);
    
    // 방장(리더)이거나 피드 작성자인 경우 삭제 권한 부여
    final bool canManage = widget.mission.leaderName == '나' || data['userId'] == myUserId;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1E1E2C), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 18, backgroundColor: Colors.blueAccent.withValues(alpha: 0.2), child: const Icon(Icons.person, color: Colors.blueAccent, size: 20)),
              const SizedBox(width: 12),
              Expanded(child: Text(data['userName'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15))),
              if (canManage)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey, size: 18),
                  color: const Color(0xFF1E1E2C),
                  onSelected: (value) {
                    if (value == 'delete') {
                      doc.reference.delete();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('삭제', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (data['imageUrl'] != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(data['imageUrl'], width: double.infinity, height: 200, fit: BoxFit.cover),
            ),
          const SizedBox(height: 12),
          Text(data['content'], style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4)),
          const SizedBox(height: 16),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (isLiked) {
                    doc.reference.update({'likes': FieldValue.arrayRemove([myUserId])});
                  } else {
                    doc.reference.update({'likes': FieldValue.arrayUnion([myUserId])});
                  }
                },
                child: Row(
                  children: [
                    Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.redAccent : Colors.grey, size: 20),
                    const SizedBox(width: 4),
                    Text('${likes.length}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () => _showCommentBottomSheet(doc),
                child: const Row(
                  children: [
                    Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 20),
                    const SizedBox(width: 4),
                    Text('댓글', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCommentBottomSheet(DocumentSnapshot feedDoc) {
    final TextEditingController commentController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E2C),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            children: [
              const Text('댓글', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              const Divider(color: Colors.white10, height: 30),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: feedDoc.reference.collection('comments').orderBy('createdAt', descending: false).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final comments = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final commentData = comments[index].data() as Map<String, dynamic>;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(radius: 14, backgroundColor: Colors.white10, child: const Icon(Icons.person, size: 16, color: Colors.grey)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(commentData['userName'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                    Text(commentData['content'], style: const TextStyle(color: Colors.white70, fontSize: 14)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: '댓글을 입력하세요...',
                        hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () async {
                      if (commentController.text.isNotEmpty) {
                        final userProvider = context.read<UserProvider>();
                        await feedDoc.reference.collection('comments').add({
                          'userId': userProvider.userId,
                          'userName': userProvider.nickname,
                          'content': commentController.text,
                          'createdAt': FieldValue.serverTimestamp(),
                        });
                        commentController.clear();
                      }
                    },
                    icon: const Icon(Icons.send, color: Colors.blueAccent),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

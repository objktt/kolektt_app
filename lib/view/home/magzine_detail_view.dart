import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../model/article.dart';
import '../../model/article_content_type.dart';
import '../../model/record.dart';


class MagazineDetailView extends StatelessWidget {
  final Article article;

  const MagazineDetailView({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        previousPageTitle: 'Kolektt',
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Image
              SizedBox(
                height: 250,
                width: MediaQuery.sizeOf(context).width,
                child: Image.network(
                  article.coverImageURL,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: CupertinoColors.systemGrey4,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Article Meta Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            article.category,
                            style: const TextStyle(
                              color: CupertinoColors.systemBlue,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Text(
                          article.formattedDate,
                          style: const TextStyle(
                            color: CupertinoColors.systemGrey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
        
                    // Title
                    Text(
                      article.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
        
                    // Subtitle
                    if (article.subtitle != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        article.subtitle!,
                        style: const TextStyle(
                          fontSize: 20,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ],
        
                    // Author Info
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ClipOval(
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: Image.network(
                              article.authorImageURL,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: CupertinoColors.systemGrey4,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article.authorName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              article.authorTitle,
                              style: const TextStyle(
                                fontSize: 12,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
        
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
        
                    // Contents
                    ...article.contents.map((content) {
                      switch (content.type) {
                        case ArticleContentType.text:
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              content.text,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.6,
                              ),
                            ),
                          );
                        case ArticleContentType.image:
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: SizedBox(
                                    height: 200,
                                    width: double.infinity,
                                    child: Image.network(
                                      content.imageURL.toString(),
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                        color: CupertinoColors.systemGrey4,
                                      ),
                                    ),
                                  ),
                                ),
                                if (content.caption != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    content.caption!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: CupertinoColors
                                          .systemGrey, // Cupertino 색상 사용
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        case ArticleContentType.relatedRecords:
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '관련 음반',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 240,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: content.records.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 16, bottom: 8),
                                        child: RecordCard(
                                            record: content.records[index]),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                      }
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecordCard extends StatelessWidget {
  final Record record;

  const RecordCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigator.push(
        //   context,
        //   CupertinoPageRoute(
        //     builder: (context) => RecordDetailView(record: record),
        //   ),
        // );
      },
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withOpacity(0.1),
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 150,
                height: 150,
                child: FadeInImage.memoryNetwork(
                  // Flutter pub.dev에서 transparent_image 패키지를 추가 후 import
                  placeholder: kTransparentImage, // 투명 placeholder (1px GIF)
                  image: record.coverImageURL!,
                  fit: BoxFit.cover,
                  // fadeInDuration 등으로 애니메이션 속도 조절
                  fadeInDuration: const Duration(milliseconds: 300),
                  imageErrorBuilder: (context, error, stackTrace) {
                    // 이미지 로딩 실패 시 표시할 위젯
                    return Container(
                      color: CupertinoColors.systemGrey4,
                      child: const Icon(
                        CupertinoIcons.photo_fill,
                        color: CupertinoColors.systemGrey,
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    record.artist,
                    style: const TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemGrey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Row(
                    children: [
                      Text(
                        '최저가',
                        style: TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                      SizedBox(width: 4),
                      // Text(
                      //   '${record.lowestPrice}원',
                      //   style: const TextStyle(
                      //     fontSize: 16,
                      //     fontWeight: FontWeight.bold,
                      //     color: CupertinoColors.systemBlue,
                      //   ),
                      // ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Models

enum ContentType {
  text,
  image,
  relatedRecords,
}

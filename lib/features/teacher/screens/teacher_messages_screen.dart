import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../common/utils/constants/colors.dart';
import '../../../common/utils/constants/sized.dart';
import '../../../common/utils/helpers/helper_function.dart';

class TeacherMessagesScreen extends StatelessWidget {
  const TeacherMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Messages',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.search_normal),
            onPressed: () {
              // Implement search functionality
            },
          ),
          IconButton(
            icon: const Icon(Iconsax.edit),
            onPressed: () {
              // Implement new message functionality
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            children: [
              // Message categories
              _buildCategorySelector(context, dark),

              const SizedBox(height: TSizes.spaceBtwSections),

              // Recent messages
              Text(
                'Recent Messages',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),

              // Message list
              _buildMessageItem(
                context: context,
                name: 'John Smith',
                message: 'Hello, I have a question about the homework.',
                time: '10:30 AM',
                isUnread: true,
                avatarText: 'JS',
                dark: dark,
              ),

              _buildMessageItem(
                context: context,
                name: 'Sarah Johnson',
                message: 'Thank you for the feedback on my project.',
                time: 'Yesterday',
                isUnread: false,
                avatarText: 'SJ',
                dark: dark,
              ),

              _buildMessageItem(
                context: context,
                name: 'Michael Brown',
                message: 'When is the next class meeting?',
                time: 'Yesterday',
                isUnread: true,
                avatarText: 'MB',
                dark: dark,
              ),

              _buildMessageItem(
                context: context,
                name: 'Emily Davis',
                message: 'I\'ve submitted my assignment.',
                time: 'Monday',
                isUnread: false,
                avatarText: 'ED',
                dark: dark,
              ),

              _buildMessageItem(
                context: context,
                name: 'David Wilson',
                message: 'Can we schedule a meeting to discuss my grades?',
                time: 'Sunday',
                isUnread: false,
                avatarText: 'DW',
                dark: dark,
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                // Handle FAB action
              },
              child: const Icon(Iconsax.add),
            ),
          ),
        ],
      ),
    );
  }

  // Build category selector (All, Unread, Important)
  Widget _buildCategorySelector(BuildContext context, bool dark) {
    final selectedCategory = 0.obs;

    return Obx(
      () => Row(
        children: [
          _buildCategoryButton(
            context: context,
            label: 'All',
            index: 0,
            selectedIndex: selectedCategory.value,
            onTap: () => selectedCategory.value = 0,
            dark: dark,
          ),
          const SizedBox(width: TSizes.spaceBtwItems),
          _buildCategoryButton(
            context: context,
            label: 'Unread',
            index: 1,
            selectedIndex: selectedCategory.value,
            onTap: () => selectedCategory.value = 1,
            dark: dark,
          ),
          const SizedBox(width: TSizes.spaceBtwItems),
          _buildCategoryButton(
            context: context,
            label: 'Important',
            index: 2,
            selectedIndex: selectedCategory.value,
            onTap: () => selectedCategory.value = 2,
            dark: dark,
          ),
        ],
      ),
    );
  }

  // Build category button
  Widget _buildCategoryButton({
    required BuildContext context,
    required String label,
    required int index,
    required int selectedIndex,
    required VoidCallback onTap,
    required bool dark,
  }) {
    final isSelected = index == selectedIndex;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: TSizes.md,
          vertical: TSizes.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (dark ? TColors.yellow : TColors.primary)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(TSizes.buttonRadius),
          border: Border.all(
            color: isSelected
                ? (dark ? TColors.yellow : TColors.primary)
                : Colors.grey,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: isSelected
                    ? (dark ? TColors.dark : Colors.white)
                    : (dark ? Colors.white : TColors.dark),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
        ),
      ),
    );
  }

  // Build message item
  Widget _buildMessageItem({
    required BuildContext context,
    required String name,
    required String message,
    required String time,
    required bool isUnread,
    required String avatarText,
    required bool dark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
      decoration: BoxDecoration(
        color: isUnread
            ? (dark
                ? TColors.darkerGrey.withOpacity(0.3)
                : TColors.light.withOpacity(0.5))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: TSizes.md,
          vertical: TSizes.sm,
        ),
        leading: CircleAvatar(
          backgroundColor: dark ? TColors.yellow : TColors.primary,
          radius: 24,
          child: Text(
            avatarText,
            style: TextStyle(
              color: dark ? TColors.dark : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight:
                          isUnread ? FontWeight.bold : FontWeight.normal,
                    ),
              ),
            ),
            Text(
              time,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
        subtitle: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                color: isUnread
                    ? (dark ? Colors.white : TColors.dark)
                    : Colors.grey,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () {
          // Navigate to message detail screen
          Get.to(
            () => _MessageDetailScreen(name: name, avatarText: avatarText),
            transition: Transition.rightToLeft,
          );
        },
      ),
    );
  }
}

// Message Detail Screen
class _MessageDetailScreen extends StatelessWidget {
  final String name;
  final String avatarText;

  const _MessageDetailScreen({
    required this.name,
    required this.avatarText,
  });

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);
    final messageController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: dark ? TColors.yellow : TColors.primary,
              radius: 18,
              child: Text(
                avatarText,
                style: TextStyle(
                  color: dark ? TColors.dark : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: TSizes.sm),
            Text(name, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.call),
            onPressed: () {
              // Implement call functionality
            },
          ),
          IconButton(
            icon: const Icon(Iconsax.more),
            onPressed: () {
              // Show more options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Message history
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              reverse: true, // Start from bottom
              children: [
                _buildReceivedMessage(
                  context,
                  'Hello, I have a question about the homework.',
                  '10:30 AM',
                  dark,
                ),
                _buildSentMessage(
                  context,
                  'Sure, what\'s your question?',
                  '10:32 AM',
                  dark,
                ),
                _buildReceivedMessage(
                  context,
                  'For problem #3, I\'m not sure how to approach it. Could you provide a hint?',
                  '10:35 AM',
                  dark,
                ),
                _buildSentMessage(
                  context,
                  'Try using the formula we discussed in class yesterday. Remember to consider the boundary conditions.',
                  '10:40 AM',
                  dark,
                ),
                _buildReceivedMessage(
                  context,
                  'That makes sense! Thank you for the help.',
                  '10:42 AM',
                  dark,
                ),
                _buildSentMessage(
                  context,
                  'You\'re welcome! Let me know if you have any other questions.',
                  '10:45 AM',
                  dark,
                ),
              ],
            ),
          ),

          // Message input
          Container(
            padding: const EdgeInsets.all(TSizes.md),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: TColors.dark.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Iconsax.attach_circle),
                  onPressed: () {
                    // Attach file
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          TSizes.borderRadiusMd,
                        ),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: dark ? TColors.darkerGrey : TColors.light,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: TSizes.md,
                        vertical: TSizes.sm,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.newline,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Iconsax.send_1,
                    color: dark ? TColors.yellow : TColors.primary,
                  ),
                  onPressed: () {
                    // Send message
                    if (messageController.text.trim().isNotEmpty) {
                      // In a real app, you would send the message to the server
                      // and update the UI accordingly
                      messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build received message bubble
  Widget _buildReceivedMessage(
    BuildContext context,
    String message,
    String time,
    bool dark,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.all(TSizes.md),
            decoration: BoxDecoration(
              color: dark ? TColors.darkerGrey : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: TSizes.xs),
                Text(
                  time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build sent message bubble
  Widget _buildSentMessage(
    BuildContext context,
    String message,
    String time,
    bool dark,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.all(TSizes.md),
            decoration: BoxDecoration(
              color: dark ? TColors.yellow : TColors.primary,
              borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: dark ? TColors.dark : Colors.white,
                      ),
                ),
                const SizedBox(height: TSizes.xs),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: dark ? TColors.dark54 : Colors.white70,
                            fontSize: 10,
                          ),
                    ),
                    const SizedBox(width: TSizes.xs),
                    Icon(
                      Iconsax.tick_circle,
                      size: 12,
                      color: dark ? TColors.dark54 : Colors.white70,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

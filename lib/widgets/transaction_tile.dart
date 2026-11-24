import 'package:flutter/material.dart';
import '../data/categories.dart';
import '../models/transaction.dart';
import '../theme.dart';
import '../utils/format.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onTap;
  const TransactionTile({super.key, required this.transaction, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final info = categoryByName(t.category);
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: info.color.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(info.icon, color: info.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text('${t.category}  •  ${formatDate(t.date)}${t.commitmentId != null ? '  •  Auto' : ''}',
                        style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                  ],
                ),
              ),
              Text(
                '${t.isExpense ? '-' : '+'}${formatMoney(t.amount)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: t.isExpense ? AppColors.expense : AppColors.income,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

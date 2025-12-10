import 'package:flutter/material.dart';

class FAQItem {
  final String question;
  final String answer;

  const FAQItem({required this.question, required this.answer});
}

class FAQSection {
  final String category;
  final List<FAQItem> items;

  const FAQSection({required this.category, required this.items});
}

const List<FAQSection> faqData = [
  FAQSection(
    category: "General Questions",
    items: [
      FAQItem(
        question: "What is CyberCart?",
        answer:
            "CyberCart is an online retail store specializing in electronics. We offer a seamless shopping experience with fast shipping, secure payments, and excellent customer service.",
      ),
      FAQItem(
        question: "How do I create an account?",
        answer:
            "Creating an account is simple:\n- Click Sign Up at the top right of our app/website.\n- Enter your name, email, and password.\n- Verify your email, and you’re ready to shop!",
      ),
      FAQItem(
        question: "How do I reset my password?",
        answer:
            "Follow these steps:\n- Click Forgot Password? on the login page.\n- Enter your registered email.\n- Follow the reset link sent to your inbox.\n- Create a new password.",
      ),
    ],
  ),
  FAQSection(
    category: "Ordering & Payments",
    items: [
      FAQItem(
        question: "How do I place an order?",
        answer:
            "1. Browse our store and add items to your cart.\n2. Proceed to checkout.\n3. Enter shipping details and payment information.\n4. Confirm your order—you’ll receive an order confirmation email.",
      ),
      FAQItem(
        question: "What payment methods do you accept?",
        answer:
            "We accept: Credit/Debit Cards (Visa, Mastercard), and Cash on Delivery (COD).",
      ),
      FAQItem(
        question: "Can I cancel my order?",
        answer:
            "You can modify/cancel your order within 1 hour of placing it. After that, contact support immediately—we’ll try our best to assist.",
      ),
    ],
  ),
  FAQSection(
    category: "Shipping & Delivery",
    items: [
      FAQItem(
        question: "How long does shipping take?",
        answer: "Standard Shipping: 3-5 business days.",
      ),
      FAQItem(
        question: "Do you offer free shipping?",
        answer: "Yes! Orders over Rs. 1999 qualify for free standard shipping.",
      ),
      FAQItem(
        question: "How do I track my order?",
        answer:
            "Use the 'Track Order' icon in the bottom navigation bar or enter your Order ID in the dedicated Tracking page. You will receive real-time updates there.",
      ),
    ],
  ),
  FAQSection(
    category: "Returns & Refunds",
    items: [
      FAQItem(
        question: "What is your return policy?",
        answer:
            "- Items must be unused, in original packaging.\n- Returns accepted within 7 days of delivery.",
      ),
      FAQItem(
        question: "How do I initiate a return?",
        answer:
            "1. Login to your account.\n2. Click My Orders on the profile screen.\n3. Click Return Item for the order you want to return.\n4. Follow the return instructions provided.",
      ),
      FAQItem(
        question: "How long do refunds take?",
        answer:
            "Once we receive your return, refunds are processed in 3-5 business days. The refund will reflect in your original payment method.",
      ),
    ],
  ),
];

class FaqsScreen extends StatelessWidget {
  const FaqsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Frequently Asked Questions",
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            ...faqData
                .expand(
                  (section) => [
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0, bottom: 5.0),
                      child: Text(
                        section.category,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Divider(height: 20),

                    ...section.items
                        .map((faq) => _FaqExpansionTile(faq: faq))
                        .toList(),
                  ],
                )
                .toList(),

            const SizedBox(height: 40),

            const _ContactUsSection(),
          ],
        ),
      ),
    );
  }
}

class _ContactUsSection extends StatelessWidget {
  const _ContactUsSection();

  Widget _buildContactTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor, size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
        onTap:
            onTap ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Simulating action for $title')),
              );
            },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Still Need Help?",
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          "Our support team is available 24/7 to assist you.",
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
        ),
        const Divider(height: 30),

        _buildContactTile(
          context,
          icon: Icons.chat_bubble_outline,
          title: 'Live Chat Support',
          subtitle: 'Get instant answers from our virtual assistant.',
          onTap: () {},
        ),
        _buildContactTile(
          context,
          icon: Icons.email_outlined,
          title: 'Email Us',
          subtitle: 'support@cybercart.com',
          onTap: () {},
        ),
        _buildContactTile(
          context,
          icon: Icons.phone_outlined,
          title: 'Call Us',
          subtitle: '+92 300 1234567',
          onTap: () {},
        ),
      ],
    );
  }
}

class _FaqExpansionTile extends StatelessWidget {
  final FAQItem faq;

  const _FaqExpansionTile({required this.faq});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            'Q. ${faq.question}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          iconColor: Theme.of(context).primaryColor,
          collapsedIconColor: Colors.grey,

          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SelectableText(
                'A. ${faq.answer}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

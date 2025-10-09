import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MessageRenderer extends StatelessWidget {
  final String text;
  final bool isUser;

  const MessageRenderer({
    super.key,
    required this.text,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    if (isUser) {
      // For user messages, just show plain text
      return Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
      );
    }

    // For AI messages, parse and render markdown with math support
    return _buildAIMessage(context);
  }

  Widget _buildAIMessage(BuildContext context) {
    // Split text by math delimiters and render accordingly
    final parts = _parseTextWithMath(text);
    
    if (parts.length == 1 && parts[0]['type'] == 'text') {
      // No math equations, use regular markdown
      return MarkdownBody(
        data: text,
        styleSheet: _getMarkdownStyleSheet(context),
        selectable: true,
      );
    }

    // Has math equations, render mixed content
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: parts.map((part) {
        if (part['type'] == 'math_inline') {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: _buildInlineMath(part['content'] as String),
          );
        } else if (part['type'] == 'math_block') {
          return _buildBlockMath(part['content'] as String);
        } else {
          // Regular text/markdown
          final content = part['content'] as String;
          if (content.trim().isEmpty) return const SizedBox.shrink();
          
          return MarkdownBody(
            data: content,
            styleSheet: _getMarkdownStyleSheet(context),
            selectable: true,
          );
        }
      }).toList(),
    );
  }

  Widget _buildInlineMath(String mathContent) {
    // Convert LaTeX to readable format
    final readableMath = _convertLatexToReadable(mathContent);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.blue[200]!, width: 1),
      ),
      child: Text(
        readableMath,
        style: TextStyle(
          color: Colors.blue[800],
          fontSize: 16,
          fontFamily: 'monospace',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildBlockMath(String mathContent) {
    // Convert LaTeX to readable format
    final readableMath = _convertLatexToReadable(mathContent);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!, width: 1),
      ),
      child: Center(
        child: Text(
          readableMath,
          style: TextStyle(
            color: Colors.blue[800],
            fontSize: 18,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  String _convertLatexToReadable(String latex) {
    String result = latex;
    
    // Common LaTeX symbols to Unicode/readable text
    final replacements = {
      // Greek letters
      r'\alpha': 'α',
      r'\beta': 'β',
      r'\gamma': 'γ',
      r'\delta': 'δ',
      r'\epsilon': 'ε',
      r'\theta': 'θ',
      r'\lambda': 'λ',
      r'\mu': 'μ',
      r'\pi': 'π',
      r'\sigma': 'σ',
      r'\phi': 'φ',
      r'\omega': 'ω',
      
      // Mathematical operators
      r'\infty': '∞',
      r'\sum': '∑',
      r'\prod': '∏',
      r'\int': '∫',
      r'\partial': '∂',
      r'\nabla': '∇',
      r'\sqrt': '√',
      r'\pm': '±',
      r'\times': '×',
      r'\div': '÷',
      r'\leq': '≤',
      r'\geq': '≥',
      r'\neq': '≠',
      r'\approx': '≈',
      r'\equiv': '≡',
      r'\in': '∈',
      r'\subset': '⊂',
      r'\cup': '∪',
      r'\cap': '∩',
      
      // Arrows
      r'\rightarrow': '→',
      r'\leftarrow': '←',
      r'\leftrightarrow': '↔',
      r'\Rightarrow': '⇒',
      r'\Leftarrow': '⇐',
      r'\Leftrightarrow': '⇔',
    };
    
    // Apply basic replacements
    replacements.forEach((latex, unicode) {
      result = result.replaceAll(latex, unicode);
    });
    
    // Handle fractions: \frac{a}{b} -> (a)/(b)
    result = result.replaceAllMapped(
      RegExp(r'\\frac\{([^}]*)\}\{([^}]*)\}'),
      (match) => '(${match.group(1)})/(${match.group(2)})',
    );
    
    // Handle superscripts: ^{text} -> ^(text) or ^char -> ^char
    result = result.replaceAllMapped(
      RegExp(r'\^(\{[^}]*\}|\w)'),
      (match) {
        String exp = match.group(1)!;
        if (exp.startsWith('{') && exp.endsWith('}')) {
          exp = exp.substring(1, exp.length - 1);
        }
        return '^($exp)';
      },
    );
    
    // Handle subscripts: _{text} -> _(text) or _char -> _char
    result = result.replaceAllMapped(
      RegExp(r'_(\{[^}]*\}|\w)'),
      (match) {
        String sub = match.group(1)!;
        if (sub.startsWith('{') && sub.endsWith('}')) {
          sub = sub.substring(1, sub.length - 1);
        }
        return '_($sub)';
      },
    );
    
    // Handle square roots: \sqrt{x} -> √(x)
    result = result.replaceAllMapped(
      RegExp(r'\\sqrt\{([^}]*)\}'),
      (match) => '√(${match.group(1)})',
    );
    
    // Handle limits and bounds
    result = result.replaceAllMapped(
      RegExp(r'\\limits_\{([^}]*)\}\^\{([^}]*)\}'),
      (match) => ' from ${match.group(1)} to ${match.group(2)}',
    );
    
    // Handle simple cases: \command{content} -> content
    result = result.replaceAllMapped(
      RegExp(r'\\(?:text|mathrm|mathbf)\{([^}]*)\}'),
      (match) => match.group(1)!,
    );
    
    // Clean up remaining LaTeX commands by removing backslashes from unknown commands
    result = result.replaceAllMapped(
      RegExp(r'\\([a-zA-Z]+)'),
      (match) => match.group(1)!,
    );
    
    // Clean up extra braces
    result = result.replaceAll(RegExp(r'\{([^}]*)\}'), r'\1');
    
    return result.trim();
  }

  List<Map<String, String>> _parseTextWithMath(String input) {
    final parts = <Map<String, String>>[];
    final text = input;
    int index = 0;

    while (index < text.length) {
      // Look for block math first ($$...$$)
      int blockStart = text.indexOf('\$\$', index);
      
      // Look for inline math ($...$) but not if it's part of block math
      int inlineStart = text.indexOf('\$', index);
      
      // If we found block math and it comes before or at the same position as inline
      if (blockStart != -1 && (inlineStart == -1 || blockStart <= inlineStart)) {
        // Add text before block math
        if (blockStart > index) {
          parts.add({
            'type': 'text',
            'content': text.substring(index, blockStart),
          });
        }
        
        // Find closing delimiter for block math
        int blockEnd = text.indexOf('\$\$', blockStart + 2);
        if (blockEnd != -1) {
          // Add block math
          final mathContent = text.substring(blockStart + 2, blockEnd).trim();
          if (mathContent.isNotEmpty) {
            parts.add({
              'type': 'math_block',
              'content': mathContent,
            });
          }
          index = blockEnd + 2;
        } else {
          // No closing delimiter, treat as regular text
          parts.add({
            'type': 'text',
            'content': '\$\$',
          });
          index = blockStart + 2;
        }
      }
      // Check for inline math ($...$) - make sure it's not part of block math
      else if (inlineStart != -1) {
        // Add text before inline math
        if (inlineStart > index) {
          parts.add({
            'type': 'text',
            'content': text.substring(index, inlineStart),
          });
        }
        
        // Find closing delimiter for inline math
        int inlineEnd = -1;
        int searchStart = inlineStart + 1;
        
        // Keep looking for single $ that's not followed by another $
        while (searchStart < text.length) {
          int nextDollar = text.indexOf('\$', searchStart);
          if (nextDollar == -1) break;
          
          // Check if this is a single $ (not $$)
          if (nextDollar + 1 >= text.length || text[nextDollar + 1] != '\$') {
            inlineEnd = nextDollar;
            break;
          }
          
          // Skip this $$ and continue looking
          searchStart = nextDollar + 2;
        }
        
        if (inlineEnd != -1) {
          // Add inline math
          final mathContent = text.substring(inlineStart + 1, inlineEnd).trim();
          if (mathContent.isNotEmpty) {
            parts.add({
              'type': 'math_inline',
              'content': mathContent,
            });
          }
          index = inlineEnd + 1;
        } else {
          // No valid closing delimiter, treat as regular text
          parts.add({
            'type': 'text',
            'content': '\$',
          });
          index = inlineStart + 1;
        }
      } else {
        // No more math delimiters, add remaining text
        final remainingText = text.substring(index);
        if (remainingText.isNotEmpty) {
          parts.add({
            'type': 'text',
            'content': remainingText,
          });
        }
        break;
      }
    }

    return parts.isEmpty ? [{'type': 'text', 'content': input}] : parts;
  }

  MarkdownStyleSheet _getMarkdownStyleSheet(BuildContext context) {
    return MarkdownStyleSheet(
      p: TextStyle(
        color: Colors.grey[800],
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      h1: TextStyle(
        color: Colors.grey[800],
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: 1.2,
      ),
      h2: TextStyle(
        color: Colors.grey[800],
        fontSize: 20,
        fontWeight: FontWeight.bold,
        height: 1.2,
      ),
      h3: TextStyle(
        color: Colors.grey[800],
        fontSize: 18,
        fontWeight: FontWeight.bold,
        height: 1.2,
      ),
      code: TextStyle(
        backgroundColor: Colors.grey[200],
        color: Colors.grey[800],
        fontFamily: 'monospace',
        fontSize: 14,
      ),
      codeblockDecoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      codeblockPadding: const EdgeInsets.all(12),
      blockquote: TextStyle(
        color: Colors.grey[600],
        fontStyle: FontStyle.italic,
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Colors.grey[400]!,
            width: 4,
          ),
        ),
      ),
      listBullet: TextStyle(
        color: Colors.grey[800],
        fontSize: 16,
      ),
      strong: TextStyle(
        color: Colors.grey[800],
        fontWeight: FontWeight.bold,
      ),
      em: TextStyle(
        color: Colors.grey[800],
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
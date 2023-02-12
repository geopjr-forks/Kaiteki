import "package:flutter/material.dart";
import "package:flutter_blurhash/flutter_blurhash.dart";
import "package:kaiteki/fediverse/model/user/user.dart";

class AvatarWidget extends StatelessWidget {
  final User user;
  final double? size;
  final VoidCallback? onTap;
  final ShapeBorder? shape;
  final FocusNode? focusNode;

  const AvatarWidget(
    this.user, {
    super.key,
    this.size = 48,
    this.onTap,
    this.shape,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final size = this.size;
    final url = user.avatarUrl;

    Widget avatar;
    final Widget fallback = SizedBox(
      width: size,
      height: size,
      child: const FallbackAvatar(),
    );

    if (url == null) {
      avatar = fallback;
    } else {
      avatar = Image.network(
        url,
        frameBuilder: _frameBuilder,
        width: size,
        height: size,
        errorBuilder: (_, __, ___) => fallback,
        fit: BoxFit.cover,
      );
    }

    if (onTap != null) {
      avatar = InkWell(onTap: onTap, focusNode: focusNode, child: avatar);
    }

    final shape = this.shape ??
        Theme.of(context).extension<AvatarTheme>()?.shape ??
        const CircleBorder();
    // ignore: join_return_with_assignment
    avatar = Material(
      clipBehavior: Clip.antiAlias,
      shape: shape,
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: avatar,
    );

    return avatar;
  }

  Widget _frameBuilder(
    BuildContext context,
    Widget child,
    int? frame,
    bool wasSynchronouslyLoaded,
  ) {
    if (wasSynchronouslyLoaded) return child;

    final blurHash = user.avatarBlurHash;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      child: frame == null
          ? SizedBox.square(
              dimension: size,
              child: blurHash != null
                  ? BlurHash(
                      color: Colors.transparent,
                      hash: blurHash,
                    )
                  : null,
            )
          : SizedBox(child: child),
    );
  }
}

class FallbackAvatar extends StatelessWidget {
  const FallbackAvatar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxHeight;
        final padding = size / 6;

        return Padding(
          padding: EdgeInsets.all(padding),
          child: Icon(
            Icons.person_rounded,
            size: size - (padding * 2),
          ),
        );
      },
    );
  }
}

class AvatarTheme extends ThemeExtension<AvatarTheme> {
  final ShapeBorder? shape;

  const AvatarTheme({this.shape});

  @override
  AvatarTheme copyWith({ShapeBorder? shape}) {
    return AvatarTheme(
      shape: shape ?? this.shape,
    );
  }

  @override
  AvatarTheme lerp(covariant AvatarTheme? other, double t) {
    return AvatarTheme(
      shape: ShapeBorder.lerp(shape, other?.shape, t),
    );
  }
}

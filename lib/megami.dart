library megami;

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

import 'css/parser.dart' hide Border, Color;
import 'css/visitor.dart';

part 'megami_colors.dart';
part 'megami_dimens.dart';
part 'megami_utils.dart';
part 'padding_box_decoration.dart';
part 'style.dart';
part 'style_animate.dart';
part 'style_components.dart';
part 'style_cubit.dart';
part 'style_exts.dart';
part 'svg.dart';
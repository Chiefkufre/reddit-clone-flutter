import 'package:fpdart/fpdart.dart';
import 'package:reddit/core/common/failure.dart';

typedef FutureEither<T> = Future<Either<Failure, T>>;
typedef FutureVoid = FutureEither<void>;

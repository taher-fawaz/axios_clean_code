import 'package:axios/core/api/request_status.dart';
import 'package:axios/core/errors/failures.dart';
import 'package:axios/features/github_users/domain/entities/github_user.dart';
import 'package:axios/features/github_users/domain/usecases/get_user_details_usecase.dart';
import 'package:axios/features/github_users/domain/usecases/get_users_usecase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'github_users_event.dart';
part 'github_users_state.dart';

class GithubUsersBloc extends Bloc<GithubUsersEvent, GithubUsersState> {
  final GetGithubUsersUseCase getGithubUsersUseCase;
  final GetGithubUserDetailsUseCase getGithubUserDetailsUseCase;

  GithubUsersBloc(
    this.getGithubUsersUseCase,
    this.getGithubUserDetailsUseCase,
  ) : super(GithubUsersState()) {
    on<GithubUsersEvent>((event, emit) async {
      if (event is GetGithubUsersEvent) {
        emit(state.copyWith(status: RequestStatus.loading));
        final result = await getGithubUsersUseCase(event.query);
        result.fold(
          (l) => emit(state.copyWith(
            status: RequestStatus.error,
            errorMessage: l,
          )),
          (r) {
            final users = r;
            emit(state.copyWith(
              status: RequestStatus.success,
              users: users,
            ));
          },
        );
      } else if (event is GetGithubUserDetailsEvent) {
        emit(state.copyWith(status: RequestStatus.loading));
        final result = await getGithubUserDetailsUseCase(event.username);
        result.fold(
          (l) => emit(state.copyWith(
            status: RequestStatus.error,
            errorMessage: l,
          )),
          (r) => emit(state.copyWith(
            status: RequestStatus.success,
            gitHubUser: r,
          )),
        );
      }
    });
  }
}

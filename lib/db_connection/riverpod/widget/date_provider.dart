// // lib/providers/follow_up_provider.dart
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:lead_application/model/follow_upDateModel.dart';
// import 'package:lead_application/riverpod/date_api_call.dart';

// final followUpServiceProvider = Provider<FollowUpService>((ref) {
//   return FollowUpService();
// });

// class FollowUpState {
//   final List<FollowUp> followUps;
//   final bool isLoading;
//   final String? errorMessage;

//   FollowUpState({
//     required this.followUps,
//     required this.isLoading,
//     this.errorMessage,
//   });

//   FollowUpState copyWith({
//     List<FollowUp>? followUps,
//     bool? isLoading,
//     String? errorMessage,
//   }) {
//     return FollowUpState(
//       followUps: followUps ?? this.followUps,
//       isLoading: isLoading ?? this.isLoading,
//       errorMessage: errorMessage ?? this.errorMessage,
//     );
//   }
// }

// class FollowUpNotifier extends StateNotifier<FollowUpState> {
//   final FollowUpService _service;

//   FollowUpNotifier(this._service)
//       : super(FollowUpState(followUps: [], isLoading: false));

//   Future<void> loadFollowUps(int leadId) async {
//     state = state.copyWith(isLoading: true);

//     try {
//       final followUps = await _service.fetchFollowUps(leadId);
//       state = state.copyWith(
//           followUps: followUps, isLoading: false, errorMessage: null);
//     } catch (e) {
//       state = state.copyWith(isLoading: false, errorMessage: e.toString());
//     }
//   }
// }

// final followUpNotifierProvider =
//     StateNotifierProvider<FollowUpNotifier, FollowUpState>((ref) {
//   final service = ref.watch(followUpServiceProvider);
//   return FollowUpNotifier(service);
// });

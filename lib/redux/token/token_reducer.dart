import 'package:redux/redux.dart';
import 'package:built_collection/built_collection.dart';
import 'package:invoiceninja_flutter/redux/app/app_actions.dart';
import 'package:invoiceninja_flutter/data/models/models.dart';
import 'package:invoiceninja_flutter/redux/company/company_actions.dart';
import 'package:invoiceninja_flutter/redux/ui/entity_ui_state.dart';
import 'package:invoiceninja_flutter/redux/token/token_actions.dart';
import 'package:invoiceninja_flutter/redux/ui/list_ui_state.dart';
import 'package:invoiceninja_flutter/redux/token/token_state.dart';
import 'package:invoiceninja_flutter/data/models/entities.dart';

EntityUIState tokenUIReducer(TokenUIState state, dynamic action) {
  return state.rebuild((b) => b
    ..listUIState.replace(tokenListReducer(state.listUIState, action))
    ..editing.replace(editingReducer(state.editing, action))
    ..selectedId = selectedIdReducer(state.selectedId, action));
}

Reducer<String> selectedIdReducer = combineReducers([
  TypedReducer<String, ViewToken>(
      (String selectedId, dynamic action) => action.tokenId),
  TypedReducer<String, AddTokenSuccess>(
      (String selectedId, dynamic action) => action.token.id),
  TypedReducer<String, SelectCompany>(
      (selectedId, action) => action.clearSelection ? '' : selectedId),
  TypedReducer<String, DeleteTokensSuccess>((selectedId, action) => ''),
  TypedReducer<String, ArchiveTokensSuccess>((selectedId, action) => ''),
  TypedReducer<String, ClearEntityFilter>((selectedId, action) => ''),
  TypedReducer<String, FilterByEntity>((selectedId, action) => action
          .clearSelection
      ? ''
      : action.entityType == EntityType.token ? action.entityId : selectedId),
]);

final editingReducer = combineReducers<TokenEntity>([
  TypedReducer<TokenEntity, SaveTokenSuccess>(_updateEditing),
  TypedReducer<TokenEntity, AddTokenSuccess>(_updateEditing),
  TypedReducer<TokenEntity, RestoreTokensSuccess>((tokens, action) {
    return action.tokens[0];
  }),
  TypedReducer<TokenEntity, ArchiveTokensSuccess>((tokens, action) {
    return action.tokens[0];
  }),
  TypedReducer<TokenEntity, DeleteTokensSuccess>((tokens, action) {
    return action.tokens[0];
  }),
  TypedReducer<TokenEntity, EditToken>(_updateEditing),
  TypedReducer<TokenEntity, UpdateToken>((token, action) {
    return action.token.rebuild((b) => b..isChanged = true);
  }),
  TypedReducer<TokenEntity, DiscardChanges>(_clearEditing),
]);

TokenEntity _clearEditing(TokenEntity token, dynamic action) {
  return TokenEntity();
}

TokenEntity _updateEditing(TokenEntity token, dynamic action) {
  return action.token;
}

final tokenListReducer = combineReducers<ListUIState>([
  TypedReducer<ListUIState, SortTokens>(_sortTokens),
  TypedReducer<ListUIState, FilterTokensByState>(_filterTokensByState),
  TypedReducer<ListUIState, FilterTokens>(_filterTokens),
  TypedReducer<ListUIState, FilterTokensByCustom1>(_filterTokensByCustom1),
  TypedReducer<ListUIState, FilterTokensByCustom2>(_filterTokensByCustom2),
  TypedReducer<ListUIState, StartTokenMultiselect>(_startListMultiselect),
  TypedReducer<ListUIState, AddToTokenMultiselect>(_addToListMultiselect),
  TypedReducer<ListUIState, RemoveFromTokenMultiselect>(
      _removeFromListMultiselect),
  TypedReducer<ListUIState, ClearTokenMultiselect>(_clearListMultiselect),
]);

ListUIState _filterTokensByCustom1(
    ListUIState tokenListState, FilterTokensByCustom1 action) {
  if (tokenListState.custom1Filters.contains(action.value)) {
    return tokenListState
        .rebuild((b) => b..custom1Filters.remove(action.value));
  } else {
    return tokenListState.rebuild((b) => b..custom1Filters.add(action.value));
  }
}

ListUIState _filterTokensByCustom2(
    ListUIState tokenListState, FilterTokensByCustom2 action) {
  if (tokenListState.custom2Filters.contains(action.value)) {
    return tokenListState
        .rebuild((b) => b..custom2Filters.remove(action.value));
  } else {
    return tokenListState.rebuild((b) => b..custom2Filters.add(action.value));
  }
}

ListUIState _filterTokensByState(
    ListUIState tokenListState, FilterTokensByState action) {
  if (tokenListState.stateFilters.contains(action.state)) {
    return tokenListState.rebuild((b) => b..stateFilters.remove(action.state));
  } else {
    return tokenListState.rebuild((b) => b..stateFilters.add(action.state));
  }
}

ListUIState _filterTokens(ListUIState tokenListState, FilterTokens action) {
  return tokenListState.rebuild((b) => b
    ..filter = action.filter
    ..filterClearedAt = action.filter == null
        ? DateTime.now().millisecondsSinceEpoch
        : tokenListState.filterClearedAt);
}

ListUIState _sortTokens(ListUIState tokenListState, SortTokens action) {
  return tokenListState.rebuild((b) => b
    ..sortAscending = b.sortField != action.field || !b.sortAscending
    ..sortField = action.field);
}

ListUIState _startListMultiselect(
    ListUIState productListState, StartTokenMultiselect action) {
  return productListState.rebuild((b) => b..selectedIds = ListBuilder());
}

ListUIState _addToListMultiselect(
    ListUIState productListState, AddToTokenMultiselect action) {
  return productListState.rebuild((b) => b..selectedIds.add(action.entity.id));
}

ListUIState _removeFromListMultiselect(
    ListUIState productListState, RemoveFromTokenMultiselect action) {
  return productListState
      .rebuild((b) => b..selectedIds.remove(action.entity.id));
}

ListUIState _clearListMultiselect(
    ListUIState productListState, ClearTokenMultiselect action) {
  return productListState.rebuild((b) => b..selectedIds = null);
}

final tokensReducer = combineReducers<TokenState>([
  TypedReducer<TokenState, SaveTokenSuccess>(_updateToken),
  TypedReducer<TokenState, AddTokenSuccess>(_addToken),
  TypedReducer<TokenState, LoadTokensSuccess>(_setLoadedTokens),
  TypedReducer<TokenState, LoadTokenSuccess>(_setLoadedToken),
  TypedReducer<TokenState, LoadCompanySuccess>(_setLoadedCompany),
  TypedReducer<TokenState, ArchiveTokensRequest>(_archiveTokenRequest),
  TypedReducer<TokenState, ArchiveTokensSuccess>(_archiveTokenSuccess),
  TypedReducer<TokenState, ArchiveTokensFailure>(_archiveTokenFailure),
  TypedReducer<TokenState, DeleteTokensRequest>(_deleteTokenRequest),
  TypedReducer<TokenState, DeleteTokensSuccess>(_deleteTokenSuccess),
  TypedReducer<TokenState, DeleteTokensFailure>(_deleteTokenFailure),
  TypedReducer<TokenState, RestoreTokensRequest>(_restoreTokenRequest),
  TypedReducer<TokenState, RestoreTokensSuccess>(_restoreTokenSuccess),
  TypedReducer<TokenState, RestoreTokensFailure>(_restoreTokenFailure),
]);

TokenState _archiveTokenRequest(
    TokenState tokenState, ArchiveTokensRequest action) {
  final tokens = action.tokenIds.map((id) => tokenState.map[id]).toList();

  for (int i = 0; i < tokens.length; i++) {
    tokens[i] = tokens[i]
        .rebuild((b) => b..archivedAt = DateTime.now().millisecondsSinceEpoch);
  }
  return tokenState.rebuild((b) {
    for (final token in tokens) {
      b.map[token.id] = token;
    }
  });
}

TokenState _archiveTokenSuccess(
    TokenState tokenState, ArchiveTokensSuccess action) {
  return tokenState.rebuild((b) {
    for (final token in action.tokens) {
      b.map[token.id] = token;
    }
  });
}

TokenState _archiveTokenFailure(
    TokenState tokenState, ArchiveTokensFailure action) {
  return tokenState.rebuild((b) {
    for (final token in action.tokens) {
      b.map[token.id] = token;
    }
  });
}

TokenState _deleteTokenRequest(
    TokenState tokenState, DeleteTokensRequest action) {
  final tokens = action.tokenIds.map((id) => tokenState.map[id]).toList();

  for (int i = 0; i < tokens.length; i++) {
    tokens[i] = tokens[i].rebuild((b) => b
      ..archivedAt = DateTime.now().millisecondsSinceEpoch
      ..isDeleted = true);
  }
  return tokenState.rebuild((b) {
    for (final token in tokens) {
      b.map[token.id] = token;
    }
  });
}

TokenState _deleteTokenSuccess(
    TokenState tokenState, DeleteTokensSuccess action) {
  return tokenState.rebuild((b) {
    for (final token in action.tokens) {
      b.map[token.id] = token;
    }
  });
}

TokenState _deleteTokenFailure(
    TokenState tokenState, DeleteTokensFailure action) {
  return tokenState.rebuild((b) {
    for (final token in action.tokens) {
      b.map[token.id] = token;
    }
  });
}

TokenState _restoreTokenRequest(
    TokenState tokenState, RestoreTokensRequest action) {
  final tokens = action.tokenIds.map((id) => tokenState.map[id]).toList();

  for (int i = 0; i < tokens.length; i++) {
    tokens[i] = tokens[i].rebuild((b) => b
      ..archivedAt = 0
      ..isDeleted = false);
  }
  return tokenState.rebuild((b) {
    for (final token in tokens) {
      b.map[token.id] = token;
    }
  });
}

TokenState _restoreTokenSuccess(
    TokenState tokenState, RestoreTokensSuccess action) {
  return tokenState.rebuild((b) {
    for (final token in action.tokens) {
      b.map[token.id] = token;
    }
  });
}

TokenState _restoreTokenFailure(
    TokenState tokenState, RestoreTokensFailure action) {
  return tokenState.rebuild((b) {
    for (final token in action.tokens) {
      b.map[token.id] = token;
    }
  });
}

TokenState _addToken(TokenState tokenState, AddTokenSuccess action) {
  return tokenState.rebuild((b) => b
    ..map[action.token.id] = action.token
    ..list.add(action.token.id));
}

TokenState _updateToken(TokenState tokenState, SaveTokenSuccess action) {
  return tokenState.rebuild((b) => b..map[action.token.id] = action.token);
}

TokenState _setLoadedToken(TokenState tokenState, LoadTokenSuccess action) {
  return tokenState.rebuild((b) => b..map[action.token.id] = action.token);
}

TokenState _setLoadedTokens(TokenState tokenState, LoadTokensSuccess action) =>
    tokenState.loadTokens(action.tokens);

TokenState _setLoadedCompany(TokenState tokenState, LoadCompanySuccess action) {
  final company = action.userCompany.company;
  return tokenState.loadTokens(company.tokens);
}

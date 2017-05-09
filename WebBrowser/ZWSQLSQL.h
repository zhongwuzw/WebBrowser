//
//  ZWSQLSQL.h
//  WebBrowser
//
//  Created by 钟武 on 2017/4/7.
//  Copyright © 2017年 钟武. All rights reserved.
//

#ifndef ZWSQLSQL_h
#define ZWSQLSQL_h

#pragma mark - History

#define ZW_TABLE_HISTORY              @"history"
#define ZW_TABLE_HISTORY_HOUR_MINUTE_INDEX @"history_hour_minute_index"

#define ZW_FIELD_URL                  @"url"
#define ZW_FIELD_TITLE                @"title"
#define ZW_FIELD_HOUR_MINUTE          @"hour_minute"
#define ZW_FIELD_TIME                 @"time"

#define ZW_SQL_CREATE_HISTORY_TABLE \
    @"CREATE TABLE IF NOT EXISTS " ZW_TABLE_HISTORY @" ("    \
        ZW_FIELD_URL             @" TEXT NOT NULL, "         \
        ZW_FIELD_TITLE           @" TEXT, "                  \
        ZW_FIELD_HOUR_MINUTE     @" TEXT, "                  \
        ZW_FIELD_TIME            @" TEXT NOT NULL, "         \
        @"PRIMARY KEY(" ZW_FIELD_URL @"," ZW_FIELD_TIME @")" \
    @");"

#define ZW_SQL_CREATE_HISTORY_INDEX_TABLE               \
    @"CREATE INDEX IF NOT EXISTS "                      \
        ZW_TABLE_HISTORY_HOUR_MINUTE_INDEX @" ON "      \
        ZW_TABLE_HISTORY @"(" ZW_FIELD_HOUR_MINUTE @");"

#define ZW_SQL_INSERT_OR_IGNORE_HISTORY                 \
    @"INSERT OR IGNORE INTO " ZW_TABLE_HISTORY  @" ("   \
        ZW_FIELD_URL             @", "                  \
        ZW_FIELD_TITLE           @", "                  \
        ZW_FIELD_HOUR_MINUTE     @", "                  \
        ZW_FIELD_TIME                                   \
    @") VALUES(?, ?, ?, ?);"

#define ZW_SQL_SELECT_HISTORY                \
    @"SELECT * FROM " ZW_TABLE_HISTORY @" ORDER BY "  \
        ZW_FIELD_TIME           @" DESC,"         \
        ZW_FIELD_HOUR_MINUTE    @" DESC "         \
    @"LIMIT ? OFFSET ?;"

#define ZW_SQL_SELECT_TODAY_YESTERDAY_HISTORY     \
    @"SELECT * FROM " ZW_TABLE_HISTORY @" "       \
        @"WHERE "     ZW_FIELD_TIME @" = ? "      \
        @"ORDER BY "  ZW_FIELD_HOUR_MINUTE @" "   \
    @"DESC;"

#define ZW_SQL_DELETE_HISTORY_RECORD     \
    @"DELETE FROM " ZW_TABLE_HISTORY @" "       \
        @"WHERE "   ZW_FIELD_URL @" = ? "       \
        @"AND "     ZW_FIELD_TIME @" = ?;"      \

#define ZW_SQL_DELETE_ALL_HISTORY_RECORD     \
    @"DELETE FROM " ZW_TABLE_HISTORY @";"

#endif /* ZWSQLSQL_h */

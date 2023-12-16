/*
 * Copyright (C) 2015 Bilibili
 * Copyright (C) 2015 Zhang Rui <bbcallen@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package tv.danmaku.ijk.media.example.fragments;

import android.app.Activity;
import android.content.ContentValues;
import android.content.Context;
import android.content.DialogInterface;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v4.app.LoaderManager;
import android.support.v4.content.Loader;
import android.support.v4.widget.SimpleCursorAdapter;
import android.support.v7.app.AlertDialog;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.Toast;

import tv.danmaku.ijk.media.example.R;
import tv.danmaku.ijk.media.example.activities.VideoActivity;
import tv.danmaku.ijk.media.example.content.RecentMediaStorage;

public class RecentMediaListFragment extends Fragment implements LoaderManager.LoaderCallbacks<Cursor> {
    private ListView mFileListView;
    private RecentMediaAdapter mAdapter;
    private AlertDialog alertDialog;

    public static RecentMediaListFragment newInstance() {
        RecentMediaListFragment f = new RecentMediaListFragment();
        return f;
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        ViewGroup viewGroup = (ViewGroup) inflater.inflate(R.layout.fragment_file_list, container, false);
        mFileListView = (ListView) viewGroup.findViewById(R.id.file_list_view);
        return viewGroup;
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);

        final Activity activity = getActivity();

        mAdapter = new RecentMediaAdapter(activity);
        mFileListView.setAdapter(mAdapter);
        mFileListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, final int position, final long id) {
                String url = mAdapter.getUrl(position);
                String name = mAdapter.getName(position);
                VideoActivity.intentTo(activity, url, name);
            }
        });
        mFileListView.setOnItemLongClickListener(new AdapterView.OnItemLongClickListener() {
            @Override // android.widget.AdapterView.OnItemLongClickListener
            public boolean onItemLongClick(AdapterView<?> adapterView, View view, final int position, long id) {
                String url = mAdapter.getUrl(position);
                if (Build.VERSION.SDK_INT >= 21) {
                    alertDialog = new AlertDialog.Builder(getContext()).setView(LayoutInflater.from(getContext()).inflate(R.layout.layout_edit, (ViewGroup) null, true)).setMessage("修改").setPositiveButton("确认", new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialogInterface, int i) {
                            mAdapter.updateUrl(position, ((EditText) alertDialog.findViewById(R.id.ed_tv)).getText().toString());
                        }
                    }).create();
                    alertDialog.show();
                    ((EditText) alertDialog.findViewById(R.id.ed_tv)).setText(url);
                }
                return true;
            }
        });

        getLoaderManager().initLoader(2, null, this);
    }

    @Override
    public Loader<Cursor> onCreateLoader(int id, Bundle args) {
        return new RecentMediaStorage.CursorLoader(getActivity());
    }

    @Override
    public void onLoadFinished(Loader<Cursor> loader, Cursor data) {
        mAdapter.swapCursor(data);
        mAdapter.notifyDataSetChanged();
    }

    @Override
    public void onLoaderReset(Loader<Cursor> loader) {

    }

    final class RecentMediaAdapter extends SimpleCursorAdapter {
        private int mIndex_id = -1;
        private int mIndex_url = -1;
        private int mIndex_name = -1;

        public RecentMediaAdapter(Context context) {
            super(context, android.R.layout.simple_list_item_2, null,
                    new String[]{RecentMediaStorage.Entry.COLUMN_NAME_NAME, RecentMediaStorage.Entry.COLUMN_NAME_URL},
                    new int[]{android.R.id.text1, android.R.id.text2}, 0);
        }

        @Override
        public Cursor swapCursor(Cursor c) {
            Cursor res = super.swapCursor(c);

            mIndex_id = c.getColumnIndex(RecentMediaStorage.Entry.COLUMN_NAME_ID);
            mIndex_url = c.getColumnIndex(RecentMediaStorage.Entry.COLUMN_NAME_URL);
            mIndex_name = c.getColumnIndex(RecentMediaStorage.Entry.COLUMN_NAME_NAME);

            return res;
        }

        @Override
        public long getItemId(int position) {
            final Cursor cursor = moveToPosition(position);
            if (cursor == null)
                return 0;

            return cursor.getLong(mIndex_id);
        }

        Cursor moveToPosition(int position) {
            final Cursor cursor = getCursor();
            if (cursor.getCount() == 0 || position >= cursor.getCount()) {
                return null;
            }
            cursor.moveToPosition(position);
            return cursor;
        }

        public String getUrl(int position) {
            final Cursor cursor = moveToPosition(position);
            if (cursor == null)
                return "";

            return cursor.getString(mIndex_url);
        }
        public void updateUrl(int position, String url) {
            Cursor cursor = moveToPosition(position);
            if (cursor != null) {
                ContentValues cv = new ContentValues();
                cv.put("url", url);
                String[] whereArgs = {cursor.getInt(this.mIndex_id) + ""};
                SQLiteDatabase db = new RecentMediaStorage.OpenHelper(getContext()).getReadableDatabase();
                try {
                    db.update(RecentMediaStorage.Entry.TABLE_NAME, cv, "id=?", whereArgs);
                    db.close();
                    cursor.requery();
                } catch (Exception e) {
                    e.printStackTrace();
                    db.close();
                    Toast.makeText(getContext(), "修改失败：已存在该内容", 0).show();
                }
            }
        }

        public String getName(int position) {
            final Cursor cursor = moveToPosition(position);
            if (cursor == null)
                return "";

            return cursor.getString(mIndex_name);
        }
    }
}

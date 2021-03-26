/*
 * JTouchBar
 *
 * Copyright (c) 2021 thizzer.com
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 *
 * @author  	C. Klein
 */
package com.thizzer.jtouchbar.item;

import java.util.List;

public class CandidateListTouchBarItem extends TouchBarItem{

    private List<String> _candidates;

    private int _rangeStart;
    private int _rangeEnd;

    private String _context;

    private CandidateListDelegate _delegate;

    public CandidateListTouchBarItem(String identifier) {
        super(identifier);
    }

    public List<String> getCandidates() {
        return _candidates;
    }

    public void setCandidates(List<String> candidates) {
        this._candidates = candidates;
        update();
    }

    public String getContext() {
        return _context;
    }

    public void setContext(String context) {
        this._context = context;
        update();
    }

    public int getRangeStart() {
        return _rangeStart;
    }

    public void setRangeStart(int rangeStart) {
        this._rangeStart = rangeStart;
        update();
    }

    public int getRangeEnd() {
        return _rangeEnd;
    }

    public void setRangeEnd(int rangeEnd) {
        this._rangeEnd = rangeEnd;
        update();
    }

    public CandidateListDelegate getDelegate() {
        return _delegate;
    }

    public void setDelegate(CandidateListDelegate delegate) {
        this._delegate = delegate;
    }

    public interface CandidateListDelegate {
        void beginSelectingCandidate(CandidateListTouchBarItem list, int index);
        void changeCandidateSelection(CandidateListTouchBarItem list, int index, int previousIndex);
        void endSelectingCandidate(CandidateListTouchBarItem list, int index);
        void candidateVisibilityChanged(CandidateListTouchBarItem list, boolean visible);
    }
}

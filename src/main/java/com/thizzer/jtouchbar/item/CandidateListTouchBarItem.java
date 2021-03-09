package com.thizzer.jtouchbar.item;

import java.util.List;

public class CandidateListTouchBarItem extends TouchBarItem{// TODO: 3/8/21 native

    private List<String> _candidates;

    private int _rangeStart;
    private int _rangeEnd;

    private String _context;

    public CandidateListTouchBarItem(String identifier) {
        super(identifier);
    }

    public interface CandidateListDelegate {
        void beginSelectingCandidate(CandidateListTouchBarItem list, int index);
        void changeCandidateSelection(CandidateListTouchBarItem list, int index, int previousIndex);
        void endSelectingCandidate(CandidateListTouchBarItem list, int index);
        void candidateVisibilityChanged(CandidateListTouchBarItem list, boolean visible);
    }
}

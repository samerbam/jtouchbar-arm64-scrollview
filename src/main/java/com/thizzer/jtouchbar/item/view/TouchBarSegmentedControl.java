package com.thizzer.jtouchbar.item.view;

import com.thizzer.jtouchbar.common.Image;

import java.util.ArrayList;
import java.util.List;

public class TouchBarSegmentedControl extends TouchBarView {// TODO: 3/8/21 native counterpart

    public static class SegmentStyle {
        public static final int NSSegmentStyleAutomatic = 0;
        public static final int NSSegmentStyleRounded = 1;
        public static final int NSSegmentStyleTexturedRounded = 2;
        public static final int NSSegmentStyleRoundRect = 3;
        public static final int NSSegmentStyleTexturedSquare = 4;
        public static final int NSSegmentStyleCapsule = 5;
        public static final int NSSegmentStyleSmallSquare = 6;
        public static final int NSSegmentStyleSeparated = 8;
    }

    private List<String> _labels;
    private List<Image> _images;

    private int _style;

    private SegmentedControlListener _action;

    public List<String> getLabels() {
        if(_labels == null) _labels = new ArrayList<>();
        return _labels;
    }

    public void setLabels(List<String> labels) {
        _labels = labels;
        update();
    }

    public List<Image> getImages() {
        if(_images == null) _images = new ArrayList<>();
        return _images;
    }

    public void setImages(List<Image> images) {
        _images = images;
        update();
    }

    public SegmentedControlListener getAction() {
        return _action;
    }

    public void setAction(SegmentedControlListener action) {
        _action = action;
        update();
    }

    public int getStyle() {
        return _style;
    }

    public void setStyle(int style) {
        _style = style;
        update();
    }

    @FunctionalInterface
    public interface SegmentedControlListener {
        void onSegmentSelected(TouchBarSegmentedControl control, int index);
    }
}

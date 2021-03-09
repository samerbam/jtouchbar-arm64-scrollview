package com.thizzer.jtouchbar.item;

import com.thizzer.jtouchbar.common.Color;

public class ColorPickerTouchBarItem extends TouchBarItem{// TODO: 3/8/21 native counterpart

    private ColorSelectedListener _action;

    public ColorPickerTouchBarItem(String identifier) {
        super(identifier);
    }

    public ColorSelectedListener getAction() {
        return _action;
    }

    public void setAction(ColorSelectedListener action) {
        _action = action;
        update();
    }

    @FunctionalInterface
    public interface ColorSelectedListener {
        void onColorSelected(ColorPickerTouchBarItem picker, Color color);
    }
}

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

import com.thizzer.jtouchbar.common.Color;

public class ColorPickerTouchBarItem extends TouchBarItem{

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

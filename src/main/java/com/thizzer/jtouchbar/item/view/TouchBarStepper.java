package com.thizzer.jtouchbar.item.view;

public class TouchBarStepper extends TouchBarView {// TODO: 3/8/21 Find whether this is worse than item ver.

    private double _minValue;
    private double _maxValue;

    private double _increment;

    private boolean _valueWraps;

    public double getMinValue() {
        return _minValue;
    }

    public void setMinValue(double minValue) {
        _minValue = minValue;
        update();
    }

    public double getMaxValue() {
        return _maxValue;
    }

    public void setMaxValue(double maxValue) {
        _maxValue = maxValue;
        update();
    }

    public double getIncrement() {
        return _increment;
    }

    public void setIncrement(double increment) {
        _increment = increment;
        update();
    }

    @FunctionalInterface
    private interface StepperActionListener {
        void onStepperChanged(TouchBarStepper stepper, double value);
    }
}

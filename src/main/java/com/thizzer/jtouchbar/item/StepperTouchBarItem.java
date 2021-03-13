package com.thizzer.jtouchbar.item;

public class StepperTouchBarItem extends TouchBarItem{

    private double _minValue;
    private double _maxValue;

    private double _increment;

    private StepperActionListener _action;

    public StepperTouchBarItem(String identifier) {
        super(identifier);
    }

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

    public StepperActionListener getAction() {
        return _action;
    }

    public void setAction(StepperActionListener action) {
        _action = action;
    }

    @FunctionalInterface
    public interface StepperActionListener {
        void onStepperChanged(StepperTouchBarItem stepper, double value);
    }
}

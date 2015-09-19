//
//  AKTriggeredAHDEnvelope.swift
//  AudioKit
//
//  Autogenerated by scripts by Aurelius Prochazka. Do not edit directly.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

/** Trigger based linear AHD envelope

Only one trigger is required to create the lifetime of this envelope.
*/
@objc class AKTriggeredAHDEnvelope : AKParameter {

    // MARK: - Properties

    private var tenv = UnsafeMutablePointer<sp_tenv>.alloc(1)
    private var tenv2 = UnsafeMutablePointer<sp_tenv>.alloc(1)

    private var trigger = AKParameter()


    /** Attack duration, in seconds. [Default Value: 0.1] */
    var attackDuration: AKParameter = akp(0.1) {
        didSet {
            attackDuration.bind(&tenv.memory.atk, right:&tenv2.memory.atk)
            dependencies.append(attackDuration)
        }
    }

    /** Hold duration, in seconds. [Default Value: 0.3] */
    var holdDuration: AKParameter = akp(0.3) {
        didSet {
            holdDuration.bind(&tenv.memory.hold, right:&tenv2.memory.hold)
            dependencies.append(holdDuration)
        }
    }

    /** Release duration, in seconds. [Default Value: 0.2] */
    var releaseDuration: AKParameter = akp(0.2) {
        didSet {
            releaseDuration.bind(&tenv.memory.rel, right:&tenv2.memory.rel)
            dependencies.append(releaseDuration)
        }
    }

    /** If set to non-zero value, tenv will multiply the envelope with an internal signal instead of just returning an enveloped signal. [Default Value: 0] */
    var mode: AKParameter = akp(0) {
        didSet {
            tenv.memory.sigmode = Int32(floor(mode.value))
            tenv2.memory.sigmode = Int32(floor(mode.value))
            dependencies.append(mode)
        }
    }

    /** Internal input signal. If sigmode variable is set, it will multiply the envelope by this variable. Most of the time, this should be updated at audiorate. [Default Value: 0] */
    var internalInput: AKParameter = akp(0) {
        didSet {
            internalInput.bind(&tenv.memory.input, right:&tenv2.memory.input)
            dependencies.append(internalInput)
        }
    }


    // MARK: - Initializers

    /** Instantiates the envelope with default values

    - parameter trigger: Input trigger. 
    */
    init(trigger sourceInput: AKParameter)
    {
        super.init()
        trigger = sourceInput
        setup()
        dependencies = [trigger]
        bindAll()
    }

    /** Instantiates the envelope with all values

    - parameter trigger: Input trigger. 
    - parameter attackDuration: Attack duration, in seconds. [Default Value: 0.1]
    - parameter holdDuration: Hold duration, in seconds. [Default Value: 0.3]
    - parameter releaseDuration: Release duration, in seconds. [Default Value: 0.2]
    */
    convenience init(
        trigger         sourceInput: AKParameter,
        attackDuration  atkInput:    AKParameter,
        holdDuration    holdInput:   AKParameter,
        releaseDuration relInput:    AKParameter)
    {
        self.init(trigger: sourceInput)
        attackDuration  = atkInput
        holdDuration    = holdInput
        releaseDuration = relInput

        bindAll()
    }

    // MARK: - Internals

    /** Bind every property to the internal envelope */
    internal func bindAll() {
        attackDuration .bind(&tenv.memory.atk, right:&tenv2.memory.atk)
        holdDuration   .bind(&tenv.memory.hold, right:&tenv2.memory.hold)
        releaseDuration.bind(&tenv.memory.rel, right:&tenv2.memory.rel)
        dependencies.append(attackDuration)
        dependencies.append(holdDuration)
        dependencies.append(releaseDuration)
    }

    /** Internal set up function */
    internal func setup() {
        sp_tenv_create(&tenv)
        sp_tenv_create(&tenv2)
        sp_tenv_init(AKManager.sharedManager.data, tenv)
        sp_tenv_init(AKManager.sharedManager.data, tenv2)
    }

    /** Computation of the next value */
    override func compute() {
        sp_tenv_compute(AKManager.sharedManager.data, tenv, &(trigger.leftOutput), &leftOutput);
        sp_tenv_compute(AKManager.sharedManager.data, tenv2, &(trigger.rightOutput), &rightOutput);
    }

    /** Release of memory */
    override func teardown() {
        sp_tenv_destroy(&tenv)
        sp_tenv_destroy(&tenv2)
    }
}

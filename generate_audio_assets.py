import os
import math
import struct
import numpy as np

def generate_caf_linear_pcm(filename, samples, sample_rate=44100):
    """
    Generates a valid Apple Core Audio Format (CAF) file containing 16-bit little-endian mono PCM data.
    Vectorized for high performance and zero clipping.
    """
    samples = np.asarray(samples, dtype=np.float32)
    # Peak normalization to -0.5 dBFS if signal has content
    peak = np.max(np.abs(samples))
    if peak > 0:
        target_peak = 10.0 ** (-0.5 / 20.0) # ~0.944
        samples = samples * (target_peak / peak)
    
    # Quantize to 16-bit PCM
    clipped = np.clip(samples * 32767.0, -32768, 32767).astype('<i2')
    pcm_data = clipped.tobytes()
    
    # CAF File structure:
    # Header: 'caff' (4 bytes), mFileVersion (2 bytes = 1), mFileFlags (2 bytes = 0)
    # Chunk 'desc': size 32 bytes
    # Chunk 'data': size 4 + len(pcm_data) bytes (4 bytes mEditCount = 0)
    caff_header = b'caff' + struct.pack('>HH', 1, 0)
    
    # AudioDescription:
    # mSampleRate (Float64), mFormatID (UInt32 'lpcm'), mFormatFlags (UInt32),
    # mBytesPerPacket (UInt32=2), mFramesPerPacket (UInt32=1), mBytesPerFrame (UInt32=2),
    # mChannelsPerFrame (UInt32=1), mBitsPerChannel (UInt32=16)
    desc_chunk_data = struct.pack(
        '>d4sIIIIII',
        float(sample_rate),
        b'lpcm',
        6, # kAudioFormatFlagIsSignedInteger (4) | kAudioFormatFlagIsLittleEndian (2)
        2, # mBytesPerPacket
        1, # mFramesPerPacket
        2, # mBytesPerFrame
        1, # mChannelsPerFrame
        16 # mBitsPerChannel
    )
    
    desc_chunk = b'desc' + struct.pack('>q', len(desc_chunk_data)) + desc_chunk_data
    data_chunk_header = b'data' + struct.pack('>q', 4 + len(pcm_data)) + struct.pack('>I', 0)
    
    os.makedirs(os.path.dirname(os.path.abspath(filename)), exist_ok=True)
    with open(filename, 'wb') as f:
        f.write(caff_header)
        f.write(desc_chunk)
        f.write(data_chunk_header)
        f.write(pcm_data)

# MARK: - DSP Utilities

def fft_filter(signal, sample_rate=44100, low_cutoff=None, high_cutoff=None, order=4):
    """
    Zero-phase Butterworth frequency-domain filter with steep, natural acoustic roll-offs.
    """
    n = len(signal)
    freqs = np.fft.rfftfreq(n, 1.0 / sample_rate)
    H = np.ones_like(freqs, dtype=np.float64)
    if low_cutoff is not None and low_cutoff > 0:
        H *= 1.0 / (1.0 + (low_cutoff / np.maximum(freqs, 1e-5)) ** (2 * order))
    if high_cutoff is not None and high_cutoff < sample_rate / 2:
        H *= 1.0 / (1.0 + (np.maximum(freqs, 1e-5) / high_cutoff) ** (2 * order))
    spectrum = np.fft.rfft(signal) * H
    return np.fft.irfft(spectrum, n)

def fft_colored_noise(n_samples, exponent, sample_rate=44100):
    """
    Generates exact colored noise by spectral shaping:
    exponent = 1.0 -> Pink noise (1/f)
    exponent = 2.0 -> Brown/Red noise (1/f^2)
    """
    white = np.random.normal(0, 1, n_samples)
    freqs = np.fft.rfftfreq(n_samples, 1.0 / sample_rate)
    scaling = np.ones_like(freqs)
    scaling[1:] = 1.0 / (freqs[1:] ** (exponent / 2.0))
    spectrum = np.fft.rfft(white) * scaling
    noise = np.fft.irfft(spectrum, n_samples)
    return noise / (np.std(noise) + 1e-9)

def apply_equal_power_crossfade(samples, fade_len):
    """
    Blends head and tail using equal-power quarter-sine curves to guarantee seamless, click-free looping.
    """
    t = np.linspace(0, 1, fade_len)
    fade_in = np.sin(0.5 * np.pi * t)
    fade_out = np.cos(0.5 * np.pi * t)
    
    head = samples[:fade_len]
    tail = samples[-fade_len:]
    blended = tail * fade_out + head * fade_in
    
    out = np.copy(samples[:-fade_len])
    out[:fade_len] = blended
    return out

# MARK: - Physical Modeling & ASMR Sound Generators

def generate_bubble_wrap(sample_rate=44100):
    """
    Authentic Bubble Wrap Pop:
    - Pre-burst polymer membrane tension (micro-crinkle).
    - Helmholtz air-cavity rupture with rapid non-linear downward pitch sweep (1350 Hz -> 380 Hz).
    - Deep acoustic low cavity thud (175 Hz).
    - Post-burst plastic crinkle granular micro-impulses.
    """
    duration = 0.09
    n = int(sample_rate * duration)
    t = np.linspace(0, duration, n, endpoint=False)
    
    # 1. Air burst sweep: f(t) = f_end + (f_start - f_end) * exp(-t / tau_f)
    f_start = 1350.0
    f_end = 380.0
    tau_f = 0.007
    phase = 2.0 * np.pi * (f_end * t + (f_start - f_end) * tau_f * (1.0 - np.exp(-t / tau_f)))
    
    # Burst envelope: ultra-fast 0.6ms attack, rapid exponential decay
    attack = np.minimum(1.0, t / 0.0006)
    decay = np.exp(-t / 0.024)
    burst = np.sin(phase) * attack * decay
    # Acoustic air shock compression
    burst = np.tanh(burst * 2.2) * 0.75
    
    # 2. Low-frequency cavity resonance (hollow thud)
    thud_decay = np.exp(-t / 0.035)
    thud = np.sin(2.0 * np.pi * 175.0 * t) * attack * thud_decay * 0.45
    
    # 3. Plastic film crinkle (bursts of high-passed micro-noise)
    white = np.random.normal(0, 1, n)
    crinkle_filter = fft_filter(white, sample_rate, low_cutoff=3500, high_cutoff=11000)
    crinkle_env = np.exp(-t / 0.018) * (1.0 + np.sin(2.0 * np.pi * 280.0 * t))
    crinkle = crinkle_filter * crinkle_env * 0.35
    
    signal = burst + thud + crinkle
    return signal

def generate_typewriter(sample_rate=44100):
    """
    Vintage Mechanical Typewriter Keystroke:
    - Pre-strike mechanical lever sliding travel.
    - Steel typebar hammer impact on paper & rubber platen (3450 Hz, 4800 Hz, 7100 Hz modes).
    - Deep platen body punch (280 Hz & 620 Hz).
    - Escapement wheel pawl click & subtle metallic ring.
    """
    duration = 0.13
    n = int(sample_rate * duration)
    t = np.linspace(0, duration, n, endpoint=False)
    
    strike_time = 0.012
    t_strike = np.maximum(0.0, t - strike_time)
    has_struck = (t >= strike_time).astype(np.float64)
    
    # 1. Pre-strike linkage slide
    pre_noise = np.random.normal(0, 1, n)
    pre_filtered = fft_filter(pre_noise, sample_rate, low_cutoff=2500, high_cutoff=6000)
    pre_env = np.exp(-((t - 0.006) / 0.004) ** 2) * (1.0 - has_struck)
    pre_click = pre_filtered * pre_env * 0.18
    
    # 2. Main hammer impact
    attack = np.minimum(1.0, t_strike / 0.0004) * has_struck
    
    # Platen rubber thud
    thud_decay = np.exp(-t_strike / 0.022)
    thud = (np.sin(2.0 * np.pi * 280.0 * t_strike) * 0.6 +
            np.sin(2.0 * np.pi * 620.0 * t_strike) * 0.4) * attack * thud_decay * 0.65
    
    # Hard steel slug modal frequencies
    slug_modes = (
        np.sin(2.0 * np.pi * 3450.0 * t_strike) * np.exp(-t_strike / 0.016) * 0.6 +
        np.sin(2.0 * np.pi * 4800.0 * t_strike) * np.exp(-t_strike / 0.011) * 0.4 +
        np.sin(2.0 * np.pi * 7100.0 * t_strike) * np.exp(-t_strike / 0.007) * 0.3
    ) * attack * 0.55
    
    # Impact transient crack
    transient = np.random.normal(0, 1, n)
    transient_filt = fft_filter(transient, sample_rate, low_cutoff=4000, high_cutoff=14000)
    transient_pop = transient_filt * attack * np.exp(-t_strike / 0.003) * 0.45
    
    # 3. Escapement pawl rebound tick (at t = 42ms)
    t_pawl = np.maximum(0.0, t - 0.042)
    pawl_struck = (t >= 0.042).astype(np.float64)
    pawl = np.sin(2.0 * np.pi * 5200.0 * t_pawl) * np.exp(-t_pawl / 0.006) * pawl_struck * 0.25
    
    signal = pre_click + thud + slug_modes + transient_pop + pawl
    return signal

def generate_gears(sample_rate=44100):
    """
    Swiss Clockwork / Watchmaker Escapement:
    - Pallet jewel strike on steel/brass escapement gear tooth.
    - Pure high-Q modal bell resonances (2920 Hz, 4680 Hz, 6850 Hz, 9200 Hz).
    - Micro-scrape of polished gear tooth meshing.
    - Precise body enclosure resonance.
    """
    duration = 0.075
    n = int(sample_rate * duration)
    t = np.linspace(0, duration, n, endpoint=False)
    
    attack = np.minimum(1.0, t / 0.0003)
    
    # High-Q modal resonances
    modes = (
        np.sin(2.0 * np.pi * 2920.0 * t) * np.exp(-t / 0.026) * 0.55 +
        np.sin(2.0 * np.pi * 4680.0 * t) * np.exp(-t / 0.018) * 0.40 +
        np.sin(2.0 * np.pi * 6850.0 * t) * np.exp(-t / 0.010) * 0.28 +
        np.sin(2.0 * np.pi * 9200.0 * t) * np.exp(-t / 0.005) * 0.20
    ) * attack
    
    # Escapement body thud
    body = np.sin(2.0 * np.pi * 840.0 * t) * np.exp(-t / 0.015) * attack * 0.35
    
    # Tooth mesh friction
    scrape_noise = np.random.normal(0, 1, n)
    scrape_filt = fft_filter(scrape_noise, sample_rate, low_cutoff=4500, high_cutoff=9500)
    scrape = scrape_filt * attack * np.exp(-t / 0.009) * 0.35
    
    # Secondary latch rebound at 28ms
    t_reb = np.maximum(0.0, t - 0.028)
    reb_struck = (t >= 0.028).astype(np.float64)
    rebound = np.sin(2.0 * np.pi * 6400.0 * t_reb) * np.exp(-t_reb / 0.007) * reb_struck * 0.22
    
    signal = modes + body + scrape + rebound
    return signal

def generate_kinetic_sand(sample_rate=44100):
    """
    Silky ASMR Kinetic Sand:
    - Velvety Pink noise foundation simulating millions of microscopic grain frictions.
    - Granular shearing micro-collisions with dynamic low-frequency undulating envelope.
    - Deep Singing Dune meditative bowl harmonics (144 Hz, 216 Hz).
    - Seamless 3.0s equal-power loop.
    """
    duration = 3.3 # 3.0s + 0.3s crossfade
    n = int(sample_rate * duration)
    t = np.linspace(0, duration, n, endpoint=False)
    
    # 1. Velvety Pink noise filtered to silky sand spectrum
    pink = fft_colored_noise(n, 1.0, sample_rate)
    sand_bed = fft_filter(pink, sample_rate, low_cutoff=180, high_cutoff=4800) * 0.55
    
    # 2. Granular shear texture: micro-impulses modulated by natural motion
    shear_noise = np.random.normal(0, 1, n)
    shear_filt = fft_filter(shear_noise, sample_rate, low_cutoff=1400, high_cutoff=6200)
    undulation = 0.5 + 0.5 * np.sin(2.0 * np.pi * 0.8 * t) * (0.8 + 0.2 * np.sin(2.0 * np.pi * 2.3 * t))
    granular = shear_filt * undulation * 0.35
    
    # 3. Singing Sand resonance (warm drone)
    drone1 = np.sin(2.0 * np.pi * 144.0 * t)
    drone2 = np.sin(2.0 * np.pi * 216.0 * t + 0.5)
    drone = (drone1 * 0.65 + drone2 * 0.35) * (0.6 + 0.4 * np.sin(2.0 * np.pi * 0.4 * t)) * 0.16
    
    combined = sand_bed + granular + drone
    # Equal-power seamless loop
    fade_len = int(sample_rate * 0.30)
    looped = apply_equal_power_crossfade(combined, fade_len)
    return looped

def generate_heavy_rain(sample_rate=44100):
    """
    Immersive Heavy Rain ASMR:
    - Atmospheric distant rain wash (Brownian 1/f^2 noise).
    - Continuous diffuse rainfall spray on foliage & wet ground.
    - Over 200 stochastic acoustic raindrop impacts with pitch drops and resonant body.
    - Seamless 4.0s equal-power loop.
    """
    duration = 4.4 # 4.0s + 0.4s crossfade
    n = int(sample_rate * duration)
    t = np.linspace(0, duration, n, endpoint=False)
    
    # 1. Deep background rain rumble (Brownian noise)
    brown = fft_colored_noise(n, 1.8, sample_rate)
    rumble = fft_filter(brown, sample_rate, low_cutoff=50, high_cutoff=450) * 0.50
    
    # 2. Diffuse rain spray (Pink noise with smooth high-frequency presence)
    pink = fft_colored_noise(n, 1.0, sample_rate)
    spray = fft_filter(pink, sample_rate, low_cutoff=800, high_cutoff=7500) * 0.45
    
    # 3. Individual acoustic raindrop impacts
    droplet_track = np.zeros(n, dtype=np.float64)
    num_drops = int(duration * 65) # ~65 drops per second
    drop_indices = np.random.randint(0, n - int(sample_rate * 0.02), num_drops)
    
    for idx in drop_indices:
        f0 = np.random.uniform(950.0, 2400.0)
        drop_dur = np.random.uniform(0.006, 0.016)
        drop_len = int(drop_dur * sample_rate)
        dt = np.linspace(0, drop_dur, drop_len, endpoint=False)
        # Drop pitch downward sweep (Helmholtz droplet bubble oscillation)
        f_sweep = f0 * (1.0 - 0.12 * (dt / drop_dur))
        drop_phase = 2.0 * np.pi * f_sweep * dt
        drop_env = np.exp(-dt / (drop_dur * 0.35))
        drop_amp = np.random.uniform(0.12, 0.35)
        droplet_track[idx:idx + drop_len] += np.sin(drop_phase) * drop_env * drop_amp
    
    combined = rumble + spray + droplet_track * 0.70
    fade_len = int(sample_rate * 0.40)
    looped = apply_equal_power_crossfade(combined, fade_len)
    return looped

def generate_stepping_snow(sample_rate=44100):
    """
    Crisp Winter Snow Crunch:
    - Rhythmic footsteps in fresh, cold powder snow.
    - Ice crystal lattice micro-fractures (sharp granular bursts at 3.5 kHz - 9.5 kHz).
    - Acoustic low-mid compression mass (140 Hz - 320 Hz thump).
    - Seamless 3.0s equal-power loop.
    """
    duration = 3.3 # 3.0s + 0.3s crossfade
    n = int(sample_rate * duration)
    t = np.linspace(0, duration, n, endpoint=False)
    
    signal = np.zeros(n, dtype=np.float64)
    
    # Two footsteps in the 3.0-second cycle
    step_times = [0.4, 1.9]
    step_duration = 0.55
    step_samples = int(sample_rate * step_duration)
    st = np.linspace(0, step_duration, step_samples, endpoint=False)
    
    for start_t in step_times:
        start_idx = int(start_t * sample_rate)
        end_idx = start_idx + step_samples
        if end_idx > n:
            continue
            
        # 1. Granular crystal fractures
        ice_noise = np.random.normal(0, 1, step_samples)
        ice_filt = fft_filter(ice_noise, sample_rate, low_cutoff=3200, high_cutoff=9500)
        
        # Micro-crackles modulation (multi-burst crunch)
        crunch_mod = (
            np.sin(2.0 * np.pi * 18.0 * st) ** 2 * 0.5 +
            np.sin(2.0 * np.pi * 37.0 * st) ** 2 * 0.3 +
            np.random.uniform(0.1, 0.9, step_samples) * 0.2
        )
        step_env = np.sin(np.pi * (st / step_duration)) ** 1.8
        crunch = ice_filt * crunch_mod * step_env * 0.65
        
        # 2. Deep snow compression thump
        thump_noise = np.random.normal(0, 1, step_samples)
        thump_filt = fft_filter(thump_noise, sample_rate, low_cutoff=90, high_cutoff=340)
        thump = thump_filt * (step_env ** 2) * 0.55
        
        signal[start_idx:end_idx] += crunch + thump
        
    # Ambient quiet cold air breath between steps
    air = fft_filter(fft_colored_noise(n, 1.0, sample_rate), sample_rate, low_cutoff=400, high_cutoff=2500) * 0.04
    combined = signal + air
    
    fade_len = int(sample_rate * 0.30)
    looped = apply_equal_power_crossfade(combined, fade_len)
    return looped

# MARK: - Main Execution

def main():
    root_dir = os.path.dirname(os.path.abspath(__file__))
    out_dir = os.path.join(root_dir, "HapticZen", "Resources", "Audio")
    os.makedirs(out_dir, exist_ok=True)
    
    generators = {
        "bubble_wrap.caf": generate_bubble_wrap,
        "kinetic_sand.caf": generate_kinetic_sand,
        "typewriter.caf": generate_typewriter,
        "gears.caf": generate_gears,
        "heavy_rain.caf": generate_heavy_rain,
        "stepping_snow.caf": generate_stepping_snow
    }
    
    print("=" * 60)
    print("Generating High-Fidelity ASMR Audio Assets (Apple CAF PCM)")
    print("=" * 60)
    
    for filename, gen_func in generators.items():
        filepath = os.path.join(out_dir, filename)
        samples = gen_func()
        generate_caf_linear_pcm(filepath, samples)
        
        duration = len(samples) / 44100.0
        peak = np.max(np.abs(samples))
        rms = np.sqrt(np.mean(samples ** 2))
        rms_db = 20.0 * np.log10(rms + 1e-9)
        file_size = os.path.getsize(filepath)
        
        print(f"-> {filename:<18} | Dur: {duration:.2f}s | Samples: {len(samples):>6} | RMS: {rms_db:>6.1f} dBFS | Size: {file_size/1024:.1f} KB")

    print("=" * 60)
    print("All audio assets generated successfully with studio acoustic modeling.")
    print("=" * 60)

if __name__ == "__main__":
    main()

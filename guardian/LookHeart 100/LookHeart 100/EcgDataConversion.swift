import Foundation

class EcgDataConversion {
    private var ecg_outData:[Float] = Array(repeating: 0.0, count: 2)
    private var xx_msl_mm:Float = 0.0
    private var xx_outdata_itw:Float = 0.0
    private var xx_outdata_S_M:Float = 0.0
    private var xx_outdata_M_M:Float = 0.0
    private var xx_finaloper:Float = 0.0
    private var xx_real_finaloper:Int64 = 0
    private var xx_msl_pp:Float = 0.0
    
    private var xx_itx_1:[Float] = Array(repeating: 0.0, count: 13)
    private var xx_s_max:[Float] = Array(repeating: 0.0, count: 13)
    private var xx_m_min:[Float] = Array(repeating: 0.0, count: 13)
    private var xx_itx:[Float] = Array(repeating: 0.0, count: 13)
    private var xx_ecgarray:[Float] = Array(repeating: 0.0, count: 13)
    
    static let shared = EcgDataConversion()
    
    func setPeakData(_ ecgData:Int) -> Int64 {
        
        ecg_outData[1] = ecg_outData[0]
        ecg_outData[0] = Float(ecgData)
        
        xx_msl_mm = Float(abs(ecg_outData[0] - ecg_outData[1]));
        xx_msl_pp = xx_maxsmin(xx_msl_mm);
        xx_outdata_itw = xx_iten(xx_msl_pp)/2;
        xx_outdata_S_M  = xx_sum_max(xx_outdata_itw);
        xx_outdata_M_M = xx_max_min(xx_outdata_S_M);
        xx_finaloper = (xx_outdata_S_M - xx_outdata_M_M);
        xx_real_finaloper = xx_iten_1(xx_finaloper) / 8
        if(xx_real_finaloper >= 1024) { xx_real_finaloper = 1024    }
        return xx_real_finaloper;
    }
    
    private func xx_maxsmin(_ num: Float) -> Float    {
        
        for i in 0..<12 {
            xx_ecgarray[i] =  xx_ecgarray[i+1]
        }

        xx_ecgarray[12]=num

        var maxvalue = xx_ecgarray[0]
        var minvalue = xx_ecgarray[0]
        
        for i in 0..<13 {
            if (xx_ecgarray[i]>=maxvalue) { maxvalue  = xx_ecgarray[i] }
            if (xx_ecgarray[i]<=minvalue) { minvalue  = xx_ecgarray[i] }
        }

        return maxvalue - minvalue
    }
    
    private func xx_iten(_ data: Float) -> Float {
        var sumit:Float = 0;

        xx_itx[12] = data

        for tx in 0..<13 {
            sumit += xx_itx[tx];
        }

        for tx in 0..<12 {
            xx_itx[tx] = xx_itx[tx+1];
        }
        

        return sumit
    }
    
    private func xx_sum_max(_ num: Float) -> Float
    {
        for z in 0..<12 {
            xx_s_max[z] =  xx_s_max[z+1]
        }

        xx_s_max[12]=num

        var maxvalue = xx_s_max[0]
        
        for o in 0..<13 {
            if (xx_s_max[o]>=maxvalue) {    maxvalue  = xx_s_max[o] }
        }

        return maxvalue
    }

    private func xx_max_min(_ num: Float) -> Float {
        
        for z in 0..<12 {
            xx_m_min[z] =  xx_m_min[z+1]
        }
        
        xx_m_min[12]=num

        var minvalue = xx_m_min[0]
        
        for o in 0..<13 {
            if (xx_m_min[o]<=minvalue)  {   minvalue  = xx_m_min[o]    }
        }

        return minvalue;
    }

    private func xx_iten_1(_ data:Float) -> Int64 {

        var sumit:Float = 0;

        xx_itx_1[12] = data;

        for tx in 0..<13 {
            sumit += xx_itx_1[tx];
        }
        
        for tx in 0..<12 {
            xx_itx_1[tx] = xx_itx_1[tx+1]
        }

        return Int64(sumit)
    }
    
}

subroutine test_gfnff_sp
   use xtb_mctc_accuracy, only : wp
   use assertion
   use xtb_mctc_systools
   use xtb_type_environment
   use xtb_type_options
   use xtb_type_molecule
   use xtb_type_data
   use xtb_gfnff_param
   use xtb_gfnff_setup
   use xtb_gfnff_eg
   use xtb_gfnff_ini
   use xtb_setparam
   use xtb_setmod
   use xtb_disp_dftd3param
   use xtb_disp_dftd4
   use xtb_gfnff_data, only : TGFFData
   use xtb_gfnff_topology, only : TGFFTopology
   use xtb_gfnff_generator, only : TGFFGenerator
   implicit none
   real(wp),parameter :: thr = 1.0e-10_wp
   integer, parameter :: nat = 8
   integer, parameter :: at(nat) = [7,15,9,9,1,1,1,1]
   real(wp),parameter :: xyz(3,nat) = reshape(&
      &[1.50040286526241_wp,-2.88219140061585_wp, 0.00000000000000_wp, &
      & 0.00000000000000_wp, 1.90142164792207_wp, 0.00000000000000_wp, &
      &-0.02649585010919_wp,-5.05651406856634_wp, 0.00000000000000_wp, &
      &-1.39762821979929_wp, 4.65236211997835_wp, 0.00000000000000_wp, &
      & 2.62205170116282_wp,-3.14316635901963_wp, 1.53958066744940_wp, &
      &-1.46489869067775_wp, 0.78885483581631_wp, 1.94964934855945_wp, &
      & 2.62205170116282_wp,-3.14316635901963_wp,-1.53958066744940_wp, &
      &-1.46489869067775_wp, 0.78885483581631_wp,-1.94964934855945_wp],&
      & shape(xyz))
   logical, parameter :: restart = .false.

   type(TMolecule)     :: mol
   type(TEnvironment)  :: env
   type(scc_results)   :: res_gff
   type(TGFFTopology) :: topo
   type(TGFFGenerator) :: gen
   type(TGFFData) :: param

   real(wp) :: etot
   real(wp), allocatable :: g(:,:)
   character(len=:),allocatable :: fnv
   integer  :: ipar

   logical  :: exist

   call init(env)
   call init(mol,at,xyz)

   call topo%zero ! FIXME

   allocate( g(3,mol%n), source = 0.0_wp )
 
   call rdpath(env%xtbpath,'.param_gfnff.xtb',fnv,exist)
   ! maybe the user provides a local parameter file, this was always
   ! an option in `xtb', so we will give it a try
   if (.not.exist) fnv = '.param_gfnff.xtb'
   call open_file(ipar,fnv,'r')
   if (ipar.eq.-1) then
      ! at this point there is no chance to recover from this error
      ! THEREFORE, we have to kill the program
      call env%terminate("Parameter file '"//fnv//"' not found!")
   endif
   if (.not.allocated(reference_c6)) call d3init(mol%n, mol%at)
   call gfnff_read_param(ipar, param)
   call close_file(ipar)
   call gfnff_input(env, mol, topo)
   call gfnff_set_param(mol%n, gen, param)

   call delete_file('gfnff_topo')
   call delete_file('charges')
   call gfnff_ini(verbose,.true.,mol,nint(mol%chrg),gen,param,topo)

   call assert_eq(topo%nbond,6)
   call assert_eq(topo%nangl,6)
   call assert_eq(topo%ntors,1)

   g = 0.0_wp
   gff_print=.true.

   call gfnff_eg(env,gff_print,mol%n,nint(mol%chrg),mol%at,mol%xyz,make_chrg, &
      & g,etot,res_gff,param,topo,.true.)

   call assert_close(res_gff%e_total,-0.76480130317838_wp,thr)
   call assert_close(res_gff%gnorm,   0.06237477492373_wp,thr)
   call assert_close(res_gff%e_bond, -0.74131049663951_wp,thr)
   call assert_close(res_gff%e_angl,  0.00633910404059_wp,thr)
   call assert_close(res_gff%e_tors,  0.00004724445432_wp,thr)
   call assert_close(res_gff%e_es,   -0.05070333390156_wp,thr*10)
   call assert_close(res_gff%e_disp, -0.00224146422313_wp,thr)
   call assert_close(res_gff%e_rep,   0.03086605590295_wp,thr)
   call assert_close(res_gff%e_hb,   -0.00003142616658_wp,thr)
   call assert_close(res_gff%e_xb,   -0.00776698664545_wp,thr)
   call assert_close(res_gff%e_batm, -0.00000000000000_wp,thr)

   call mol%deallocate
   call gfnff_param_dealloc(topo)

   call terminate(afail)
end subroutine test_gfnff_sp

subroutine test_gfnff_hb
   use xtb_mctc_accuracy, only : wp
   use assertion
   use xtb_mctc_systools
   use xtb_type_environment
   use xtb_type_options
   use xtb_type_molecule
   use xtb_type_data
   use xtb_gfnff_param
   use xtb_gfnff_setup
   use xtb_gfnff_eg
   use xtb_gfnff_ini
   use xtb_setparam
   use xtb_setmod
   use xtb_disp_dftd3param
   use xtb_disp_dftd4
   use xtb_gfnff_data, only : TGFFData
   use xtb_gfnff_topology, only : TGFFTopology
   use xtb_gfnff_generator, only : TGFFGenerator
   implicit none
   real(wp),parameter :: thr = 1.0e-10_wp
   integer, parameter :: nat = 7
   integer, parameter :: at(nat) = [6,8,1,1,8,1,1]
   real(wp),parameter :: xyz(3,nat) = reshape(&
      &[-5.78520874132429_wp,-1.92328475821000_wp,-0.02944611115854_wp, &
      & -5.57801768832583_wp, 0.17912532844037_wp, 0.72444143178660_wp, &
      & -4.27822256938673_wp,-2.74845397256109_wp,-1.13038073598642_wp, &
      & -7.47879539136783_wp,-2.97570121473211_wp, 0.39488815557786_wp, &
      & -0.83005338399036_wp, 2.43458470560665_wp,-0.78566331969245_wp, &
      & -0.74201439536855_wp, 4.04199055249898_wp, 0.09144422329636_wp, &
      & -2.44679415487233_wp, 1.69392751177087_wp,-0.27417668699116_wp],&
      & shape(xyz))
   logical, parameter :: restart = .false.

   type(TMolecule)     :: mol
   type(TEnvironment)  :: env
   type(scc_results)   :: res_gff
   type(TGFFTopology) :: topo
   type(TGFFGenerator) :: gen
   type(TGFFData) :: param

   real(wp) :: etot
   real(wp), allocatable :: g(:,:)
   character(len=:),allocatable :: fnv
   integer  :: ipar

   logical  :: exist

   call init(env)
   call init(mol,at,xyz)

   call topo%zero ! FIXME

   allocate( g(3,mol%n), source = 0.0_wp )
 
   call rdpath(env%xtbpath,'.param_gfnff.xtb',fnv,exist)
   ! maybe the user provides a local parameter file, this was always
   ! an option in `xtb', so we will give it a try
   if (.not.exist) fnv = '.param_gfnff.xtb'
   call open_file(ipar,fnv,'r')
   if (ipar.eq.-1) then
      ! at this point there is no chance to recover from this error
      ! THEREFORE, we have to kill the program
      call env%terminate("Parameter file '"//fnv//"' not found!")
   endif
   if (.not.allocated(reference_c6)) call d3init(mol%n, mol%at)
   call gfnff_read_param(ipar, param)
   call close_file(ipar)
   call gfnff_input(env, mol, topo)
   call gfnff_set_param(mol%n, gen, param)

   call delete_file('gfnff_topo')
   call delete_file('charges')
   call gfnff_ini(verbose,.true.,mol,nint(mol%chrg),gen,param,topo)

   call assert_eq(topo%nbond,5)
   call assert_eq(topo%nangl,4)
   call assert_eq(topo%ntors,1)

   g = 0.0_wp
   gff_print=.true.

   call gfnff_eg(env,gff_print,mol%n,nint(mol%chrg),mol%at,mol%xyz,make_chrg, &
      & g,etot,res_gff,param,topo,.true.)

   call assert_close(res_gff%e_total,-0.949706677118_wp,thr)
   call assert_close(res_gff%gnorm,   0.001152720923_wp,thr)
   call assert_close(res_gff%e_bond, -0.856707643513_wp,thr)
   call assert_close(res_gff%e_angl,  0.000579711773_wp,thr)
   call assert_close(res_gff%e_tors,  0.000000008811_wp,thr)
   call assert_close(res_gff%e_es,   -0.152313816530_wp,thr*10)
   call assert_close(res_gff%e_disp, -0.001251669186_wp,thr)
   call assert_close(res_gff%e_rep,   0.066881023899_wp,thr)
   call assert_close(res_gff%e_hb,   -0.0068942923371_wp,thr)
   call assert_close(res_gff%e_xb,   -0.0000000000000_wp,thr)
   call assert_close(res_gff%e_batm, -0.0000000000000_wp,thr)

   call mol%deallocate
   call gfnff_param_dealloc(topo)

   call terminate(afail)
end subroutine test_gfnff_hb
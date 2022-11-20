classdef Fator_de_Potencia_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        Grafico                         matlab.ui.control.UIAxes
        AmplitudedaCorrenteReativaCorrenteEficazLabel  matlab.ui.control.Label
        Irms                            matlab.ui.control.NumericEditField
        AmplitudedaTensoReativaTensoEficazLabel  matlab.ui.control.Label
        Vrms                            matlab.ui.control.NumericEditField
        FasedaCorrenteLabel             matlab.ui.control.Label
        Fase                            matlab.ui.control.Slider
        FrequnciaHzEditFieldLabel       matlab.ui.control.Label
        Frequencia                      matlab.ui.control.NumericEditField
        SituaodaCorrenteEditFieldLabel  matlab.ui.control.Label
        SituacaoCorrente                matlab.ui.control.EditField
        ComponenteButtonGroup           matlab.ui.container.ButtonGroup
        ResistnciaPuraButton            matlab.ui.control.RadioButton
        IndutorPuroButton               matlab.ui.control.RadioButton
        CapacitorPuroButton             matlab.ui.control.RadioButton
        ResistorCapacitorButton         matlab.ui.control.RadioButton
        ResistorIndutorMotorButton      matlab.ui.control.RadioButton
        TipodaCorrenteLabel             matlab.ui.control.Label
        TipoCorrente                    matlab.ui.control.EditField
        PotnciaMdiaouAtivaWEditFieldLabel  matlab.ui.control.Label
        PotenciaAtiva                   matlab.ui.control.NumericEditField
        TextArea                        matlab.ui.control.TextArea
        ContextMenu                     matlab.ui.container.ContextMenu
        Menu                            matlab.ui.container.Menu
        Menu2                           matlab.ui.container.Menu
        PotnciaReativaVArEditFieldLabel  matlab.ui.control.Label
        PotenciaReativa                 matlab.ui.control.NumericEditField
        PotnciaAparenteVAEditFieldLabel  matlab.ui.control.Label
        PotenciaAparente                matlab.ui.control.NumericEditField
        FatordePotnciaEditFieldLabel    matlab.ui.control.Label
        FatorDePotencia                 matlab.ui.control.NumericEditField
        PerdasJouleLabel                matlab.ui.control.Label
        PerdasJoulicas                  matlab.ui.control.NumericEditField
        ResistnciadosCondutoresOhmsLabel  matlab.ui.control.Label
        Resistencia                     matlab.ui.control.NumericEditField
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Value changed function: Fase
        function CalcularButtonPushed(app, event)
            f = app.Frequencia.Value;
            R = app.Resistencia.Value;
            w = 2*pi*f;
            Vrms = app.Vrms.Value;
            t = linspace(0,0.1,100e3);
            v = sqrt(2)*Vrms .*sin(w*t);
            Irms = app.Irms.Value;
            fase = app.Fase.Value;
            i = sqrt(2)*Irms .*sin(w*t + fase*pi/180);
            p = v.*i;
            plot(app.Grafico, t,v, t,i, t,p);
            if fase<0
                app.SituacaoCorrente.Value = "Atrasada";
                if fase == -90
                    app.TipoCorrente.Value = "Indutiva Pura";
                    app.Grafico.Title.String = "Gráfico de U, I e P com Indutor Puro";
                    app.ComponenteButtonGroup.SelectedObject = app.IndutorPuroButton;
                else
                    app.TipoCorrente.Value = "Resistiva-Indutiva";
                    app.Grafico.Title.String = "Gráfico de U, I e P com Resistor-Indutor (Motor de Indução)";
                    app.ComponenteButtonGroup.SelectedObject = app.ResistorIndutorMotorButton;
                end
            elseif fase>0
                app.SituacaoCorrente.Value = "Adiantada";
                if fase == 90
                    app.TipoCorrente.Value = "Capacitiva Pura";
                    app.Grafico.Title.String = "Gráfico de U, I e P com Capacitor Puro";
                    app.ComponenteButtonGroup.SelectedObject = app.CapacitorPuroButton;
                else
                    app.TipoCorrente.Value = "Resistiva-Capacitiva";
                    app.Grafico.Title.String = "Gráfico de U, I e P com Resistor-Capacitor (Motor Síncrono)";
                    app.ComponenteButtonGroup.SelectedObject = app.ResistorCapacitorButton;
                end
            else
                app.SituacaoCorrente.Value = "Em Fase";
                app.TipoCorrente.Value = "Resistiva Pura";
                app.Grafico.Title.String = "Gráfico de U, I e P com Resistor Puro (Forno Resistivo)";
                app.ComponenteButtonGroup.SelectedObject = app.ResistnciaPuraButton;
            end
            if (app.TipoCorrente.Value=="Capacitiva Pura" || app.TipoCorrente.Value=="Indutiva Pura")
                Q = Vrms*Irms*sin(-fase*pi/180);
                app.PotenciaReativa.Value = Q;
                S = Vrms*Irms;
                app.PotenciaAparente.Value = S;
                P = 0;
                app.PotenciaAtiva.Value = P;
                PJ = R*(Irms^2); % Perdas Joulicas
                app.PerdasJoulicas.Value = PJ;
            elseif app.TipoCorrente.Value=="Resistiva Pura"
                Q = 0;
                app.PotenciaReativa.Value = Q;
                P = Vrms*Irms;
                app.PotenciaAtiva.Value = P;
                S = Vrms*Irms;
                app.PotenciaAparente.Value = S;
                PJ = R*(Irms^2);
                app.PerdasJoulicas.Value = PJ;
            else
                Q = Vrms*Irms*sin(-fase*pi/180);
                app.PotenciaReativa.Value = Q;
                S = Vrms*Irms;
                app.PotenciaAparente.Value = S;
                P = Vrms*Irms*cos(-fase*pi/180); % Potência Média ou Ativa
                app.PotenciaAtiva.Value = P;
                PJ = R*(Irms^2); % Perdas Joulicas
                app.PerdasJoulicas.Value = PJ;
            end
            FP = P/S; % Fator de Potência
            app.FatorDePotencia.Value = FP;
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [0.7294 0.9098 0.9882];
            app.UIFigure.Position = [100 100 733 518];
            app.UIFigure.Name = 'MATLAB App';

            % Create Grafico
            app.Grafico = uiaxes(app.UIFigure);
            title(app.Grafico, 'Gráfico de Tensão, Corrente e Potência')
            xlabel(app.Grafico, 'Tempo')
            ylabel(app.Grafico, 'Amplitudes')
            app.Grafico.PlotBoxAspectRatio = [3 1 1];
            app.Grafico.XGrid = 'on';
            app.Grafico.YGrid = 'on';
            app.Grafico.BackgroundColor = [0.7294 0.9098 0.9882];
            app.Grafico.Position = [211 207 500 206];

            % Create AmplitudedaCorrenteReativaCorrenteEficazLabel
            app.AmplitudedaCorrenteReativaCorrenteEficazLabel = uilabel(app.UIFigure);
            app.AmplitudedaCorrenteReativaCorrenteEficazLabel.FontWeight = 'bold';
            app.AmplitudedaCorrenteReativaCorrenteEficazLabel.FontColor = [0.6353 0.0784 0.1843];
            app.AmplitudedaCorrenteReativaCorrenteEficazLabel.Position = [22 277 190 28];
            app.AmplitudedaCorrenteReativaCorrenteEficazLabel.Text = {'Amplitude da Corrente Reativa'; '(Corrente Eficaz)'};

            % Create Irms
            app.Irms = uieditfield(app.UIFigure, 'numeric');
            app.Irms.FontWeight = 'bold';
            app.Irms.Position = [22 248 92 22];

            % Create AmplitudedaTensoReativaTensoEficazLabel
            app.AmplitudedaTensoReativaTensoEficazLabel = uilabel(app.UIFigure);
            app.AmplitudedaTensoReativaTensoEficazLabel.FontWeight = 'bold';
            app.AmplitudedaTensoReativaTensoEficazLabel.FontColor = [0 0.4471 0.7412];
            app.AmplitudedaTensoReativaTensoEficazLabel.Position = [22 207 186 28];
            app.AmplitudedaTensoReativaTensoEficazLabel.Text = {'Amplitude da Tensão Reativa'; '(Tensão Eficaz)'};

            % Create Vrms
            app.Vrms = uieditfield(app.UIFigure, 'numeric');
            app.Vrms.FontWeight = 'bold';
            app.Vrms.Position = [29 177 85 22];

            % Create FasedaCorrenteLabel
            app.FasedaCorrenteLabel = uilabel(app.UIFigure);
            app.FasedaCorrenteLabel.HorizontalAlignment = 'right';
            app.FasedaCorrenteLabel.Position = [63 71 99 22];
            app.FasedaCorrenteLabel.Text = 'Fase da Corrente';

            % Create Fase
            app.Fase = uislider(app.UIFigure);
            app.Fase.Limits = [-90 90];
            app.Fase.ValueChangedFcn = createCallbackFcn(app, @CalcularButtonPushed, true);
            app.Fase.Position = [38 61 150 3];

            % Create FrequnciaHzEditFieldLabel
            app.FrequnciaHzEditFieldLabel = uilabel(app.UIFigure);
            app.FrequnciaHzEditFieldLabel.HorizontalAlignment = 'right';
            app.FrequnciaHzEditFieldLabel.Position = [22 146 92 22];
            app.FrequnciaHzEditFieldLabel.Text = 'Frequência (Hz)';

            % Create Frequencia
            app.Frequencia = uieditfield(app.UIFigure, 'numeric');
            app.Frequencia.Position = [29 107 85 22];

            % Create SituaodaCorrenteEditFieldLabel
            app.SituaodaCorrenteEditFieldLabel = uilabel(app.UIFigure);
            app.SituaodaCorrenteEditFieldLabel.HorizontalAlignment = 'right';
            app.SituaodaCorrenteEditFieldLabel.Position = [147 177 119 22];
            app.SituaodaCorrenteEditFieldLabel.Text = 'Situação da Corrente';

            % Create SituacaoCorrente
            app.SituacaoCorrente = uieditfield(app.UIFigure, 'text');
            app.SituacaoCorrente.Enable = 'off';
            app.SituacaoCorrente.Position = [275 177 101 22];

            % Create ComponenteButtonGroup
            app.ComponenteButtonGroup = uibuttongroup(app.UIFigure);
            app.ComponenteButtonGroup.Title = 'Componente';
            app.ComponenteButtonGroup.BackgroundColor = [0.7294 0.9098 0.9882];
            app.ComponenteButtonGroup.Position = [207 8 214 152];

            % Create ResistnciaPuraButton
            app.ResistnciaPuraButton = uiradiobutton(app.ComponenteButtonGroup);
            app.ResistnciaPuraButton.Enable = 'off';
            app.ResistnciaPuraButton.Text = 'Resistência Pura';
            app.ResistnciaPuraButton.Position = [11 106 113 22];
            app.ResistnciaPuraButton.Value = true;

            % Create IndutorPuroButton
            app.IndutorPuroButton = uiradiobutton(app.ComponenteButtonGroup);
            app.IndutorPuroButton.Enable = 'off';
            app.IndutorPuroButton.Text = 'Indutor Puro';
            app.IndutorPuroButton.Position = [11 84 88 22];

            % Create CapacitorPuroButton
            app.CapacitorPuroButton = uiradiobutton(app.ComponenteButtonGroup);
            app.CapacitorPuroButton.Enable = 'off';
            app.CapacitorPuroButton.Text = 'Capacitor Puro';
            app.CapacitorPuroButton.Position = [11 62 102 22];

            % Create ResistorCapacitorButton
            app.ResistorCapacitorButton = uiradiobutton(app.ComponenteButtonGroup);
            app.ResistorCapacitorButton.Enable = 'off';
            app.ResistorCapacitorButton.Text = 'Resistor-Capacitor';
            app.ResistorCapacitorButton.Position = [11 41 121 22];

            % Create ResistorIndutorMotorButton
            app.ResistorIndutorMotorButton = uiradiobutton(app.ComponenteButtonGroup);
            app.ResistorIndutorMotorButton.Enable = 'off';
            app.ResistorIndutorMotorButton.Text = 'Resistor-Indutor (Motor)';
            app.ResistorIndutorMotorButton.Position = [11 20 149 22];

            % Create TipodaCorrenteLabel
            app.TipodaCorrenteLabel = uilabel(app.UIFigure);
            app.TipodaCorrenteLabel.HorizontalAlignment = 'right';
            app.TipodaCorrenteLabel.Position = [376 177 95 22];
            app.TipodaCorrenteLabel.Text = 'Tipo da Corrente';

            % Create TipoCorrente
            app.TipoCorrente = uieditfield(app.UIFigure, 'text');
            app.TipoCorrente.Enable = 'off';
            app.TipoCorrente.Position = [480 177 183 22];

            % Create PotnciaMdiaouAtivaWEditFieldLabel
            app.PotnciaMdiaouAtivaWEditFieldLabel = uilabel(app.UIFigure);
            app.PotnciaMdiaouAtivaWEditFieldLabel.FontWeight = 'bold';
            app.PotnciaMdiaouAtivaWEditFieldLabel.FontColor = [0.9294 0.6941 0.1255];
            app.PotnciaMdiaouAtivaWEditFieldLabel.Enable = 'off';
            app.PotnciaMdiaouAtivaWEditFieldLabel.Position = [432 143 166 22];
            app.PotnciaMdiaouAtivaWEditFieldLabel.Text = 'Potência Média ou Ativa (W)';

            % Create PotenciaAtiva
            app.PotenciaAtiva = uieditfield(app.UIFigure, 'numeric');
            app.PotenciaAtiva.Enable = 'off';
            app.PotenciaAtiva.Position = [597 143 123 22];

            % Create TextArea
            app.TextArea = uitextarea(app.UIFigure);
            app.TextArea.FontSize = 24;
            app.TextArea.FontWeight = 'bold';
            app.TextArea.FontColor = [1 1 1];
            app.TextArea.BackgroundColor = [0.098 0 1];
            app.TextArea.Position = [1 421 733 98];
            app.TextArea.Value = {'ESTUDO GRÁFICO DE FASORES, POTÊNCIAS MÉDIAS E VALORES EFICAZES EM CORRENTE ALTERNADA'; 'Por Lucas Gonçalves de Oliveira Martins'};

            % Create ContextMenu
            app.ContextMenu = uicontextmenu(app.UIFigure);
            
            % Assign app.ContextMenu
            app.IndutorPuroButton.ContextMenu = app.ContextMenu;

            % Create Menu
            app.Menu = uimenu(app.ContextMenu);
            app.Menu.Text = 'Menu';

            % Create Menu2
            app.Menu2 = uimenu(app.ContextMenu);
            app.Menu2.Text = 'Menu2';

            % Create PotnciaReativaVArEditFieldLabel
            app.PotnciaReativaVArEditFieldLabel = uilabel(app.UIFigure);
            app.PotnciaReativaVArEditFieldLabel.Enable = 'off';
            app.PotnciaReativaVArEditFieldLabel.Position = [432 109 129 22];
            app.PotnciaReativaVArEditFieldLabel.Text = 'Potência Reativa (VAr)';

            % Create PotenciaReativa
            app.PotenciaReativa = uieditfield(app.UIFigure, 'numeric');
            app.PotenciaReativa.Enable = 'off';
            app.PotenciaReativa.Position = [574 109 137 22];

            % Create PotnciaAparenteVAEditFieldLabel
            app.PotnciaAparenteVAEditFieldLabel = uilabel(app.UIFigure);
            app.PotnciaAparenteVAEditFieldLabel.Enable = 'off';
            app.PotnciaAparenteVAEditFieldLabel.Position = [432 79 131 22];
            app.PotnciaAparenteVAEditFieldLabel.Text = 'Potência Aparente (VA)';

            % Create PotenciaAparente
            app.PotenciaAparente = uieditfield(app.UIFigure, 'numeric');
            app.PotenciaAparente.Enable = 'off';
            app.PotenciaAparente.Position = [574 79 137 22];

            % Create FatordePotnciaEditFieldLabel
            app.FatordePotnciaEditFieldLabel = uilabel(app.UIFigure);
            app.FatordePotnciaEditFieldLabel.Enable = 'off';
            app.FatordePotnciaEditFieldLabel.Position = [432 50 122 22];
            app.FatordePotnciaEditFieldLabel.Text = 'Fator de Potência (%)';

            % Create FatorDePotencia
            app.FatorDePotencia = uieditfield(app.UIFigure, 'numeric');
            app.FatorDePotencia.Enable = 'off';
            app.FatorDePotencia.Position = [574 50 137 22];

            % Create PerdasJouleLabel
            app.PerdasJouleLabel = uilabel(app.UIFigure);
            app.PerdasJouleLabel.Enable = 'off';
            app.PerdasJouleLabel.Position = [432 20 121 22];
            app.PerdasJouleLabel.Text = 'Perdas Joule';

            % Create PerdasJoulicas
            app.PerdasJoulicas = uieditfield(app.UIFigure, 'numeric');
            app.PerdasJoulicas.Enable = 'off';
            app.PerdasJoulicas.Position = [574 20 137 22];

            % Create ResistnciadosCondutoresOhmsLabel
            app.ResistnciadosCondutoresOhmsLabel = uilabel(app.UIFigure);
            app.ResistnciadosCondutoresOhmsLabel.Position = [22 345 190 28];
            app.ResistnciadosCondutoresOhmsLabel.Text = {'Resistência dos'; 'Condutores (Ohms)'};

            % Create Resistencia
            app.Resistencia = uieditfield(app.UIFigure, 'numeric');
            app.Resistencia.Position = [22 316 92 22];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Fator_de_Potencia_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end